import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  String _getWeatherDescription(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return 'Nắng';
      case WeatherType.partlyCloudy:
        return 'Nhiều mây';
      case WeatherType.rainy:
        return 'Mưa';
      case WeatherType.rainThunder:
        return 'Mưa dông';
      case WeatherType.moon:
        return 'Đêm quang đãng';
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
    final subtitle = _isLoading
        ? 'Đang tải...'
        : _error.isNotEmpty || _weatherData == null
        ? 'Không thể tải'
        : _getWeatherDescription(_weatherData!.currentWeatherType);
    final temperature = _isLoading || _error.isNotEmpty || _weatherData == null
        ? '--°C'
        : '${_weatherData!.currentTemperature.toDouble().round()}°C';
    final iconAsset = _isLoading || _error.isNotEmpty || _weatherData == null
        ? AppVectors.weatherPartlyCloudy
        : _getWeatherIcon(_weatherData!.currentWeatherType);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Weather()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.text_color_50, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            spacing: 10.0,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary_main,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: SvgPicture.asset(iconAsset, width: 28, height: 28),
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
    );
  }
}
