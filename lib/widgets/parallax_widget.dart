import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:diary/services/weather_service.dart';
import 'package:diary/theme/app_colors.dart';
import 'package:diary/screens/weather_page.dart';

class ParallaxWidget extends StatefulWidget {
  const ParallaxWidget({super.key});

  @override
  State<ParallaxWidget> createState() => _ParallaxWidgetState();
}

class _ParallaxWidgetState extends State<ParallaxWidget> {
  String? _weatherCondition;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await WeatherService.getWeatherCondition();
      setState(() {
        _weatherCondition = weather;
      });
    } catch (e) {
      print('❌ Failed to load weather in parallax: $e');
    }
  }

  String getWeatherLottieAsset(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/lottie_weather/clear.json';
      case 'clouds':
        return 'assets/lottie_weather/cloud.json';
      case 'rain':
        return 'assets/lottie_weather/rain.json';
      default:
        return 'assets/lottie_weather/default.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.mistWhite : AppColors.deepCharcoal;

    return Stack(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: _weatherCondition == null
              ? const Center(child: CircularProgressIndicator())
              : Lottie.asset(
                  getWeatherLottieAsset(_weatherCondition!),
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.wb_sunny, color: Colors.amber, size: 28),
            tooltip: "Weather Forecast",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeatherPage()),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, Fasihah! 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (_weatherCondition != null)
                Text(
                  "Today's weather: ${_weatherCondition!.toUpperCase()}",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
