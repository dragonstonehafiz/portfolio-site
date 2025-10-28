import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core palette
  static const Color primary = Color(0xFF0288D1); // deep accent blue
  static const Color secondary = Color(0xFF4FC3F7); // lighter companion tone
  static const Color accent = Color(0xFF00B0FF); // vivid highlight

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
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
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
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
