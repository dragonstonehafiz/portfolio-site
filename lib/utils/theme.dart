import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary sky blue
  static const Color sky = Color(0xFF4FC3F7); // light sky blue
  static const Color skyDark = Color(0xFF0288D1); // darker variant for appbar
  static const Color skyAccent = Color(0xFF00B0FF);

  // Neutral backgrounds and text
  static const Color background = Color(0xFFF6FBFF);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F1724);
  static const Color textSecondary = Color(0xFF6B7280);

  // Footer / muted
  static const Color footerBg = Color(0xFF263238);
}

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.skyDark,
      primary: AppColors.skyDark,
      secondary: AppColors.skyAccent,
      background: AppColors.background,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.skyDark,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.skyDark,
        foregroundColor: Colors.white,
      ),
    ),
  );
}