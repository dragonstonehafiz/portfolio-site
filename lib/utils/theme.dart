import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final base = ThemeData.light();

  return base.copyWith(
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
    // Use Google Fonts for a cleaner modern UI
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.45, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
  );
}
