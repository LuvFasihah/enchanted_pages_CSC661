import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary/theme/theme_provider.dart';
import 'package:diary/theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/weather_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
  sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Fasihah\'s Diary',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: AppColors.luminousLavender,
              scaffoldBackgroundColor: AppColors.lightBackground,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.luminousLavender,
                foregroundColor: AppColors.deepCharcoal,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: AppColors.cyberAqua,
              ),
              cardColor: AppColors.lightCard,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(fontSize: 16, color: AppColors.deepCharcoal),
                bodyMedium: TextStyle(fontSize: 14, color: AppColors.deepCharcoal),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.midnightMist,
              scaffoldBackgroundColor: AppColors.midnightMist,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.midnightMist,
                foregroundColor: AppColors.mistWhite,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: AppColors.crimsonBloom,
              ),
              cardColor: AppColors.astralGray,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(fontSize: 16, color: AppColors.mistWhite),
                bodyMedium: TextStyle(fontSize: 14, color: AppColors.mistWhite),
              ),
            ),
            home: const SplashScreen(),
            routes: {
              '/weather': (context) => const WeatherPage(),
            },
          );
        },
      ),
    );
  }
}
