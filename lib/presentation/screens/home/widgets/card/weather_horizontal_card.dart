import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class WeatherHorizontalCard extends StatelessWidget {
  final int temperature;
  final String date;
  final WeatherType weatherType;
  const WeatherHorizontalCard({
    super.key,
    required this.temperature,
    required this.date,
    required this.weatherType,
  });

  @override
  Widget build(BuildContext context) {
    String weatherAsset;
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 70.sp,
            child: Text(
              date,
              style: AppTextStyles.s16Medium(color: AppColors.primary_800),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(70),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
            child: SvgPicture.asset(weatherAsset, width: 40.sp, height: 40.sp),
          ),
          Text(
            "$temperature°C",
            style: AppTextStyles.s16Medium(color: AppColors.primary_800),
          ),
        ],
      ),
    );
  }
}
