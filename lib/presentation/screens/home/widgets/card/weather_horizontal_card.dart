import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          SvgPicture.asset(weatherAsset, width: 40, height: 40),
          Text(
            "$temperature°C",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
