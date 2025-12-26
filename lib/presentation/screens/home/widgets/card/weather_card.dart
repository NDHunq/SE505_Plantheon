import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/weather_service.dart';
import 'package:se501_plantheon/data/models/weather.model.dart';
import 'package:se501_plantheon/presentation/screens/home/weather.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String _error = '';
  // Vị trí mặc định giống màn hình chi tiết thời tiết
  static const double _defaultLat = 10.8704192;
  static const double _defaultLon = 106.79953;

  @override
  void initState() {
    super.initState();
    _fetchWeatherPreview();
  }

  Future<void> _fetchWeatherPreview() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await _weatherService.fetchWeather(_defaultLat, _defaultLon);
      if (!mounted) return;
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải thời tiết';
        _isLoading = false;
      });
    }
  }

  String _getWeatherDescription(WeatherType type, bool isDay) {
    // Nếu là ban đêm và thời tiết là sunny, hiển thị "Trời quang"
    if (!isDay && type == WeatherType.sunny) {
      return 'Đêm quang';
    }

    switch (type) {
      case WeatherType.sunny:
        return 'Nắng';
      case WeatherType.partlyCloudy:
        return 'Có mây';
      case WeatherType.rainy:
        return 'Mưa';
      case WeatherType.rainThunder:
        return 'Mưa dông';
      case WeatherType.smallRainy:
        return 'Mưa nhẹ';
      case WeatherType.cloud:
        return 'Nhiều mây';
    }
  }

  String _getWeatherIcon(WeatherType type, bool isDay) {
    // Nếu ban đêm, hiển thị icon mặt trăng cho sunny và partlyCloudy
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
    final subtitle = _isLoading
        ? 'Đang tải thời tiết...'
        : _error.isNotEmpty || _weatherData == null
        ? 'Không thể tải'
        : _getWeatherDescription(
            _weatherData!.currentWeatherType,
            _weatherData!.currentIsDay,
          );
    final temperature = _isLoading || _error.isNotEmpty || _weatherData == null
        ? '25°C'
        : '${_weatherData!.currentTemperature.toDouble().round()}°C';
    final iconAsset = _isLoading || _error.isNotEmpty || _weatherData == null
        ? AppVectors.weatherPartlyCloudy
        : _getWeatherIcon(
            _weatherData!.currentWeatherType,
            _weatherData!.currentIsDay,
          );

    return GestureDetector(
      onTap: () async {
        // Check location permission
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          // Request permission
          permission = await Geolocator.requestPermission();

          if (permission == LocationPermission.denied) {
            // Permission denied, don't navigate
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          // Permission permanently denied, show settings dialog
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) => BasicDialog(
              title: "Cần quyền truy cập vị trí",
              content:
                  "Ứng dụng cần quyền truy cập vị trí để hiển thị thông tin thời tiết. Vui lòng cấp quyền trong cài đặt.",
              cancelText: "Hủy",
              confirmText: "Đi đến cài đặt",
              onCancel: () {
                Navigator.of(context).pop();
              },
              onConfirm: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
            ),
          );
          return;
        }

        // Permission granted, get current location
        try {
          Position position = await Geolocator.getCurrentPosition();
          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Weather(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            ),
          );
        } catch (e) {
          // If getting location fails, don't navigate
          print('Error getting location: $e');
        }
      },
      child: Skeletonizer(
        enabled: _isLoading,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100.sp),
            border: Border.all(color: AppColors.text_color_50, width: 1.sp),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0.sp,
              vertical: 8.0.sp,
            ),
            child: Row(
              spacing: 10.0.sp,
              children: [
                Container(
                  width: 44.sp,
                  height: 44.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary_main,
                    borderRadius: BorderRadius.circular(100.sp),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconAsset,
                      width: 28.sp,
                      height: 28.sp,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bây giờ,',
                      style: AppTextStyles.s16Medium(
                        color: AppColors.primary_main,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.s12Regular(
                        color: AppColors.text_color_200,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  temperature,
                  style: AppTextStyles.s20Bold(color: AppColors.primary_600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
