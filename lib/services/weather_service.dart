import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _apiKey = '60d5f4ba40fd630116ceca167446e6d2';
  static const _city = 'Kuala Terengganu,MY';

  static Future<String> getWeatherCondition() async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$_apiKey&units=metric');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final weatherMain = data['weather'][0]['main']; // e.g., "Clear", "Clouds", "Rain"
      return weatherMain;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  static Future<Map<String, String>> getWeatherEmoji() async {
    final condition = await getWeatherCondition();
    final emoji = _getEmoji(condition);
    return {
      'condition': condition,
      'emoji': emoji,
    };
  }

  static String _getEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      default:
        return '🌤️'; // Default emoji for unknown conditions
    }
  }
}
