import 'package:flutter/material.dart';
import 'package:diary/theme/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
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
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.midnightMist,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.astralGray,
    foregroundColor: AppColors.mistWhite,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.enchantedIndigo,
  ),
  cardColor: AppColors.astralGray,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.mistWhite),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.mistWhite),
  ),
);
