import 'package:se501_plantheon/core/configs/enums/weather_type.dart';

class WeatherData {
  final double latitude;
  final double longitude;
  final DateTime currentTime;
  final double currentTemperature;
  final double currentHumidity;
  final double currentWindSpeed;
  final WeatherType currentWeatherType;
  final bool currentIsDay;
  final List<HourlyWeather> hourlyWeather;
  final List<DailyWeather> dailyWeather;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.currentTime,
    required this.currentTemperature,
    required this.currentHumidity,
    required this.currentWindSpeed,
    required this.currentWeatherType,
    required this.currentIsDay,
    required this.hourlyWeather,
    required this.dailyWeather,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    // Ánh xạ mã thời tiết của Open-Meteo sang WeatherType
    WeatherType getWeatherType(int code) {
      switch (code) {
        case 0:
        case 1:
          return WeatherType.sunny;
        case 2:
        case 3:
          return WeatherType.partlyCloudy;
        case 45:
        case 48:
          return WeatherType.cloud;
        case 51:
        case 53:
        case 55:
        case 56:
        case 57:
        case 61:
        case 80:
          return WeatherType.smallRainy;
        case 63:
        case 65:
        case 66:
        case 67:
        case 81:
        case 82:
          return WeatherType.rainy;
        case 95:
        case 96:
        case 99:
          return WeatherType.rainThunder;
        default:
          return WeatherType.partlyCloudy;
      }
    }

    // Parse dữ liệu hiện tại
    final currentTime = DateTime.parse(current['time'] as String);

    // Parse dữ liệu hàng giờ
    final hourlyTimes = (hourly['time'] as List).cast<String>();
    final hourlyTemps = (hourly['temperature_2m'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final hourlyCodes = (hourly['weathercode'] as List).cast<int>();
    final hourlyIsDay = (hourly['is_day'] as List).cast<int>();
    final hourlyWeather = List.generate(
      hourlyTimes.length,
      (i) => HourlyWeather(
        time: DateTime.parse(hourlyTimes[i]),
        temperature: hourlyTemps[i],
        weatherType: getWeatherType(hourlyCodes[i]),
        isDay: hourlyIsDay[i] == 1,
      ),
    );

    // Parse dữ liệu hàng ngày
    final dailyTimes = (daily['time'] as List).cast<String>();
    final dailyTemps = (daily['temperature_2m_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final dailyCodes = (daily['weathercode'] as List).cast<int>();
    final dailyWeather = List.generate(
      dailyTimes.length,
      (i) => DailyWeather(
        date: DateTime.parse(dailyTimes[i]),
        temperature: dailyTemps[i],
        weatherType: getWeatherType(dailyCodes[i]),
      ),
    );

    return WeatherData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      currentTime: currentTime,
      currentTemperature: (current['temperature_2m'] as num).toDouble(),
      currentHumidity: (current['relative_humidity_2m'] as num).toDouble(),
      currentWindSpeed: (current['wind_speed_10m'] as num).toDouble(),
      currentWeatherType: getWeatherType(current['weathercode'] as int),
      currentIsDay: (current['is_day'] as int) == 1,
      hourlyWeather: hourlyWeather,
      dailyWeather: dailyWeather,
    );
  }
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final WeatherType weatherType;
  final bool isDay;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherType,
    required this.isDay,
  });
}

class DailyWeather {
  final DateTime date;
  final double temperature;
  final WeatherType weatherType;

  DailyWeather({
    required this.date,
    required this.temperature,
    required this.weatherType,
  });
}
