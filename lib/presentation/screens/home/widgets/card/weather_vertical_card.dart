import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class WeatherVerticalCard extends StatelessWidget {
  final bool isNow;
  final int temperature;
  final int hour;
  final WeatherType weatherType;
  const WeatherVerticalCard({
    super.key,
    this.isNow = false,
    required this.temperature,
    required this.hour,
    required this.weatherType,
  });

  @override
  Widget build(BuildContext context) {
    String weatherAsset;
    switch (weatherType) {
      case WeatherType.moon:
        weatherAsset = AppVectors.weatherMoon;
        break;
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
    }
    return Container(
      decoration: isNow
          ? BoxDecoration(
              color: AppColors.primary_300,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.text_color_50, width: 1),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.all(isNow ? 8.0 : 0),
        child: Column(
          spacing: 12,
          children: [
            Text(
              "$temperature°C",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
            SvgPicture.asset(weatherAsset, width: 40, height: 40),
            Text(
              "${hour.toString().padLeft(2, '0')}:00",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
