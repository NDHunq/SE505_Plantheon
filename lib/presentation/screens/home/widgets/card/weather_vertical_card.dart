import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class WeatherVerticalCard extends StatelessWidget {
  final bool isSelected;
  final int temperature;
  final int hour;
  final WeatherType weatherType;
  final bool isDay;
  final VoidCallback? onTap;
  const WeatherVerticalCard({
    super.key,
    this.isSelected = false,
    required this.temperature,
    required this.hour,
    required this.weatherType,
    required this.isDay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String weatherAsset;

    // Nếu ban đêm, hiển thị icon mặt trăng cho sunny và partlyCloudy
    if (!isDay && weatherType == WeatherType.sunny) {
      weatherAsset = AppVectors.weatherMoon;
    } else if (!isDay && weatherType == WeatherType.partlyCloudy) {
      weatherAsset = AppVectors.weatherPartlyCloudyMoon;
    } else {
      switch (weatherType) {
        case WeatherType.sunny:
          weatherAsset = AppVectors.weatherSunny;
          break;
        case WeatherType.rainy:
          weatherAsset = AppVectors.weatherRainy;
          break;
        case WeatherType.rainThunder:
          weatherAsset = AppVectors.weatherRainThunder;
          break;
        case WeatherType.partlyCloudy:
          weatherAsset = AppVectors.weatherPartlyCloudy;
          break;
        case WeatherType.smallRainy:
          weatherAsset = AppVectors.weatherSmallRainy;
          break;
        case WeatherType.cloud:
          weatherAsset = AppVectors.weatherCloudy;
          break;
      }
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary_400,
                borderRadius: BorderRadius.circular(25.sp),
                border: Border.all(
                  color: AppColors.white.withAlpha(100),
                  width: 1.sp,
                ),
              )
            : null,
        child: Padding(
          padding: EdgeInsets.all(isSelected ? 8.0.sp : 0.sp),
          child: Column(
            spacing: 12.sp,
            children: [
              Text(
                "$temperature°C",
                style: AppTextStyles.s16Medium(color: AppColors.white),
              ),
              SvgPicture.asset(weatherAsset, width: 40.sp, height: 40.sp),
              Text(
                "${hour.toString().padLeft(2, '0')}:00",
                style: AppTextStyles.s16Medium(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
