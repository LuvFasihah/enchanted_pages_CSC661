import 'package:flutter/material.dart';
import 'package:diary/screens/home_screen.dart';
import 'package:diary/services/weather_service.dart';
import 'package:diary/sql_helper.dart';
import 'package:diary/theme/app_colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      await SQLHelper.getDiaries();
      await WeatherService.getWeatherCondition();
    } catch (e) {
      debugPrint("Initialization error: $e");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.midnightMist : AppColors.luminousLavender;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/loading_bg.gif',
          fit: BoxFit.cover,
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.crimsonBloom,
                ),
                const SizedBox(height: 24),
                Text(
                  "Loading your enchanted diary...",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.mistWhite : AppColors.deepCharcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}