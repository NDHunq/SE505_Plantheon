import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/models/weather.model.dart';

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weathercode,is_day'
      '&hourly=temperature_2m,weathercode,is_day'
      '&daily=temperature_2m_max,weathercode'
      '&timezone=Asia/Bangkok'
      '&forecast_days=7',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Fetched weather data: $jsonData'); // Để debug
        return WeatherData.fromJson(jsonData);
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
