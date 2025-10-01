import 'package:se501_plantheon/core/configs/enums/weather_type.dart';

class WeatherData {
  final double latitude;
  final double longitude;
  final DateTime currentTime;
  final double currentTemperature;
  final double currentHumidity;
  final double currentWindSpeed;
  final WeatherType currentWeatherType;
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
          return WeatherType.sunny;
        case 1:
        case 2:
        case 3:
          return WeatherType.partlyCloudy;
        case 45:
        case 48:
          return WeatherType.partlyCloudy; // Mây mù nhẹ
        case 61:
        case 63:
        case 65:
          return WeatherType.rainy;
        case 80:
        case 81:
        case 82:
          return WeatherType.rainy; // Mưa nhẹ đến vừa
        case 95:
        case 96:
        case 99:
          return WeatherType.rainThunder; // Sét và mưa
        default:
          return WeatherType.partlyCloudy; // Mặc định
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
    final hourlyWeather = List.generate(
      hourlyTimes.length,
      (i) => HourlyWeather(
        time: DateTime.parse(hourlyTimes[i]),
        temperature: hourlyTemps[i],
        weatherType: getWeatherType(hourlyCodes[i]),
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
      hourlyWeather: hourlyWeather,
      dailyWeather: dailyWeather,
    );
  }
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final WeatherType weatherType;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherType,
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
