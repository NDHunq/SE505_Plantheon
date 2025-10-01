import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/weather_service.dart';
import 'package:se501_plantheon/data/models/weather.model.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/weather_horizontal_card.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/weather_vertical_card.dart';

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  String _error = '';
  bool _isLoading = false;
  String _locationName = 'Bình Thạnh';
  double _latitude = 10.75;
  double _longitude = 106.75;

  @override
  void initState() {
    super.initState();
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
        title: "Tính năng vị trí không khả dụng",
        content:
            "Hiện tại ứng dụng đang sử dụng vị trí mặc định: Bình Thạnh, TP.HCM",
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

  String _getWeatherDescription(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return "Nắng";
      case WeatherType.partlyCloudy:
        return "Nhiều mây";
      case WeatherType.rainy:
        return "Mưa";
      case WeatherType.rainThunder:
        return "Mưa dông";
      case WeatherType.moon:
        return "Đêm quang đãng";
    }
  }

  String _getWeatherIcon(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return AppVectors.weatherSunny;
      case WeatherType.partlyCloudy:
        return AppVectors.weatherPartlyCloudy;
      case WeatherType.rainy:
        return AppVectors.weatherRainy;
      case WeatherType.rainThunder:
        return AppVectors.weatherRainThunder;
      case WeatherType.moon:
        return AppVectors.weatherMoon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary_400,
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
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppVectors.location,
              width: 24.sp,
              height: 24.sp,
              color: AppColors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => BasicDialog(
                  title:
                      "Cho phép truy cập vị trí của bạn khi bạn dùng ứng dụng?",
                  content:
                      "Vị trí của bạn sẽ được sử dụng để tra cứu thời tiết.",
                  onConfirm: () async {
                    Navigator.of(context).pop();
                    await _getCurrentLocation();
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  confirmText: "Cho phép",
                  cancelText: "Không cho phép",
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: AppColors.white),
              ),
            )
          : _weatherData == null
          ? const Center(
              child: Text('No data', style: TextStyle(color: AppColors.white)),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      _getWeatherIcon(_weatherData!.currentWeatherType),
                      width: 110.sp,
                      height: 110.sp,
                    ),
                    SizedBox(width: 60.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatCurrentDate(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary_700,
                          ),
                        ),
                        Text(
                          '${_weatherData!.currentTemperature.toDouble().round()}°C',
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          _getWeatherDescription(
                            _weatherData!.currentWeatherType,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary_700,
                          ),
                        ),
                        Text(
                          'Độ ẩm: ${_weatherData!.currentHumidity.toDouble().round()}% - Gió: ${_weatherData!.currentWindSpeed.toDouble().round()} km/h',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary_700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.sp),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 20.sp,
                      children: _weatherData!.hourlyWeather
                          .where(
                            (hourly) =>
                                hourly.time.isAfter(DateTime.now()) ||
                                hourly.time.hour == DateTime.now().hour,
                          )
                          .take(7) // Lấy 7 giờ tiếp theo (bao gồm giờ hiện tại)
                          .map((hourly) {
                            return WeatherVerticalCard(
                              temperature: hourly.temperature
                                  .toDouble()
                                  .round(),
                              hour: hourly.time.hour,
                              weatherType: hourly.weatherType,
                              isNow: hourly.time.hour == DateTime.now().hour,
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(height: 24.sp),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary_200,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.sp),
                        topRight: Radius.circular(20.sp),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12.sp,
                          children: [
                            Text(
                              'Dự báo kế tiếp',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary_700,
                              ),
                            ),
                            ..._weatherData!.dailyWeather.asMap().entries.map((
                              entry,
                            ) {
                              final daily = entry.value;
                              final date = daily.date;
                              String dateText = entry.key == 0
                                  ? 'Hôm nay'
                                  : entry.key == 1
                                  ? 'Ngày mai'
                                  : DateFormat('EEEE', 'vi').format(date);
                              return WeatherHorizontalCard(
                                date: dateText,
                                temperature: daily.temperature
                                    .toDouble()
                                    .round(),
                                weatherType: daily.weatherType,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
