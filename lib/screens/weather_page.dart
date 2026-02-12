import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_colors.dart';
import 'main_screen.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    const apiKey = '60d5f4ba40fd630116ceca167446e6d2';
    const city = 'Kuala Terengganu,MY'; 
    final url ='https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load weather');
    }
  }

  String getWeatherEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'rain':
        return '🌧️';
      case 'cloud':
        return '☁️';
      default:
        return '🌤️';
    }
  }

  String getLottieAsset(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/lottie_weather/clear.json';
      case 'rain':
        return 'assets/lottie_weather/rain.json';
      case 'cloud':
        return 'assets/lottie_weather/cloud.json';
      default:
        return 'assets/lottie_weather/default.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen(selectedIndex: 0)),
              (route) => false, 
            );
          },
        ),     
          title: const Text("Weather Forecast"),
        backgroundColor:
            isDark ? AppColors.enchantedIndigo : AppColors.luminousLavender,
        foregroundColor: isDark ? AppColors.mistWhite : AppColors.deepCharcoal,
      ),
      backgroundColor:
          isDark ? AppColors.midnightMist : AppColors.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : weatherData == null
              ? const Center(child: Text("Failed to load weather data."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        weatherData!["name"],
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Lottie.asset(
                        getLottieAsset(weatherData!["weather"][0]["main"]),
                        height: 150,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${getWeatherEmoji(weatherData!["weather"][0]["main"])} ${weatherData!["weather"][0]["description"].toString().toUpperCase()}",
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Temperature: ${weatherData!["main"]["temp"]} °C",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        "Humidity: ${weatherData!["main"]["humidity"]}%",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
    );
  }
}



