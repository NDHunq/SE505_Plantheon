import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/services/weather_service.dart';
import 'package:se501_plantheon/data/models/weather.model.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/weather_horizontal_card.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/weather_vertical_card.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/weather_suggestion_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/domain/usecases/activity/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/delete_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/activity/update_activity.dart';

class Weather extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const Weather({super.key, this.latitude, this.longitude});

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  String _error = '';
  bool _isLoading = false;
  String _locationName = 'Thủ Đức';
  double _latitude = 10.8704192;
  double _longitude = 106.79953;
  int? _selectedHourIndex; // Lưu index của giờ được chọn

  @override
  void initState() {
    super.initState();
    // Initialize with provided coordinates or use defaults
    if (widget.latitude != null && widget.longitude != null) {
      _latitude = widget.latitude!;
      _longitude = widget.longitude!;
      _locationName = 'Vị trí hiện tại';
    }
    _initializeLocale();
    _fetchWeather();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('vi', null);
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await _weatherService.fetchWeather(_latitude, _longitude);
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('API Error: $e');
      setState(() {
        _error = 'Lỗi kết nối API: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if geolocator is available (not on web)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationDialog();
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName = 'Vị trí hiện tại';
      });
      await _fetchWeather();
    } catch (e) {
      // Fallback for web or when geolocator is not available
      _showLocationDialog();
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => BasicDialog(
        title: "Định vị không khả dụng",
        content:
            "Hiện tại ứng dụng đang sử dụng vị trí mặc định: Thủ Đức, TP.HCM",
        confirmText: "OK",
        onConfirm: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final day = now.day;
    final month = now.month;
    return "Hôm nay, $day tháng $month";
  }

  String _getWeatherDescription(WeatherType type, bool isDay) {
    // Nếu là ban đêm và thời tiết là sunny, hiển thị "Trời quang"
    if (!isDay && type == WeatherType.sunny) {
      return "Đêm quang";
    }

    switch (type) {
      case WeatherType.sunny:
        return "Nắng";
      case WeatherType.partlyCloudy:
        return "Có mây";
      case WeatherType.rainy:
        return "Mưa";
      case WeatherType.rainThunder:
        return "Mưa dông";
      case WeatherType.smallRainy:
        return "Mưa nhẹ";
      case WeatherType.cloud:
        return "Nhiều mây";
    }
  }

  String _getWeatherIcon(WeatherType type, bool isDay) {
    if (!isDay) {
      if (type == WeatherType.sunny) {
        return AppVectors.weatherMoon;
      }
      if (type == WeatherType.partlyCloudy) {
        return AppVectors.weatherPartlyCloudyMoon;
      }
    }

    switch (type) {
      case WeatherType.sunny:
        return AppVectors.weatherSunny;
      case WeatherType.partlyCloudy:
        return AppVectors.weatherPartlyCloudy;
      case WeatherType.rainy:
        return AppVectors.weatherRainy;
      case WeatherType.rainThunder:
        return AppVectors.weatherRainThunder;
      case WeatherType.smallRainy:
        return AppVectors.weatherSmallRainy;
      case WeatherType.cloud:
        return AppVectors.weatherCloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Repository
    final activitiesRepository = ActivitiesRepositoryImpl(
      remoteDataSource: ActivitiesRemoteDataSourceImpl(client: http.Client()),
    );

    return BlocProvider(
      create: (context) => ActivitiesBloc(
        getActivitiesByMonth: GetActivitiesByMonth(activitiesRepository),
        getActivitiesByDay: GetActivitiesByDay(activitiesRepository),
        createActivity: CreateActivity(activitiesRepository),
        updateActivity: UpdateActivity(activitiesRepository),
        deleteActivity: DeleteActivity(activitiesRepository),
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary_main,
        appBar: BasicAppbar(
          title: _locationName,
          titleColor: AppColors.white,
          leading: IconButton(
            icon: SvgPicture.asset(
              AppVectors.arrowBack,
              width: 28.sp,
              height: 28.sp,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _isLoading
            ? const LoadingIndicator()
            : _error.isNotEmpty
            ? Center(
                child: Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s14Regular(color: AppColors.white),
                ),
              )
            : _weatherData == null
            ? Center(
                child: Text(
                  'No data',
                  style: AppTextStyles.s14Regular(color: AppColors.white),
                ),
              )
            : Builder(
                builder: (context) {
                  // Lấy danh sách các giờ tiếp theo
                  final futureHourlyWeather = _weatherData!.hourlyWeather
                      .where(
                        (hourly) =>
                            hourly.time.isAfter(DateTime.now()) ||
                            hourly.time.hour == DateTime.now().hour,
                      )
                      .take(7)
                      .toList();

                  // Nếu chưa chọn giờ nào, mặc định chọn giờ hiện tại (index 0)
                  if (_selectedHourIndex == null ||
                      _selectedHourIndex! >= futureHourlyWeather.length) {
                    _selectedHourIndex = 0;
                  }

                  final selectedHourlyWeather =
                      futureHourlyWeather[_selectedHourIndex!];

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(top: 8.sp),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(10),
                                borderRadius: BorderRadius.circular(24.sp),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.sp,
                                vertical: 8.sp,
                              ),

                              child: SvgPicture.asset(
                                _getWeatherIcon(
                                  selectedHourlyWeather.weatherType,
                                  selectedHourlyWeather.isDay,
                                ),
                                width: 110.sp,
                                height: 110.sp,
                              ),
                            ),
                            SizedBox(width: 24.sp),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedHourlyWeather.time.hour ==
                                          DateTime.now().hour
                                      ? _formatCurrentDate()
                                      : 'Hôm nay, ${selectedHourlyWeather.time.hour.toString().padLeft(2, '0')}:00',
                                  style: AppTextStyles.s14Bold(
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  '${selectedHourlyWeather.temperature.toDouble().round()}°C',
                                  style: AppTextStyles.s36Bold(
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  _getWeatherDescription(
                                    selectedHourlyWeather.weatherType,
                                    selectedHourlyWeather.isDay,
                                  ),
                                  style: AppTextStyles.s14Medium(
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  'Độ ẩm: ${_weatherData!.currentHumidity.toDouble().round()}% - Gió: ${_weatherData!.currentWindSpeed.toDouble().round()} km/h',
                                  style: AppTextStyles.s12Medium(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.sp),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.sp),
                          child: WeatherSuggestionWidget(
                            weatherData: _weatherData!,
                          ),
                        ),
                        SizedBox(height: 16.sp),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.sp),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 20.sp,
                              children: futureHourlyWeather.asMap().entries.map(
                                (entry) {
                                  final index = entry.key;
                                  final hourly = entry.value;
                                  return WeatherVerticalCard(
                                    temperature: hourly.temperature
                                        .toDouble()
                                        .round(),
                                    hour: hourly.time.hour,
                                    weatherType: hourly.weatherType,
                                    isDay: hourly.isDay,
                                    isSelected: index == _selectedHourIndex,
                                    onTap: () {
                                      setState(() {
                                        _selectedHourIndex = index;
                                      });
                                    },
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.sp),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary_100,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.sp),
                              topRight: Radius.circular(20.sp),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 12.sp,
                              children: [
                                Text(
                                  'Dự báo kế tiếp',
                                  style: AppTextStyles.s16SemiBold(
                                    color: AppColors.primary_800,
                                  ),
                                ),
                                ..._weatherData!.dailyWeather
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final daily = entry.value;
                                      final date = daily.date;
                                      String dateText = entry.key == 0
                                          ? 'Hôm nay'
                                          : entry.key == 1
                                          ? 'Ngày mai'
                                          : DateFormat(
                                              'EEEE',
                                              'vi',
                                            ).format(date);
                                      return WeatherHorizontalCard(
                                        date: dateText,
                                        temperature: daily.temperature
                                            .toDouble()
                                            .round(),
                                        weatherType: daily.weatherType,
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
