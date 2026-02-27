import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Core palette
  static const Color primary = Color(0xFF0288D1); // deep accent blue
  static const Color secondary = Color(0xFF4FC3F7); // lighter companion tone
  static const Color accent = Color(0xFF00B0FF); // vivid highlight

  // Ocean waves theme colors
  static const Color oceanBlue = Color(0xFF1565C0);    // Deep ocean blue
  static const Color oceanTeal = Color(0xFF00ACC1);    // Vibrant teal
  static const Color oceanGreen = Color(0xFF26A69A);   // Sea green

  // Neutral backgrounds and text
  static const Color background = Color(0xFFF6FBFF);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F1724);
  static const Color textSecondary = Color(0xFF6B7280);

  static const LinearGradient scaffoldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF7FBFF)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient headerFooterGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [oceanTeal, oceanBlue, oceanGreen],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [oceanTeal, oceanGreen],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFF0F9FF)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF0FBFD)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient previewGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAF4FF), Color(0xFFDAEEFF), Color(0xFFCAE8FF)],
    stops: [0.0, 0.5, 1.0],
  );
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
    scaffoldBackgroundColor: Colors.transparent, // Changed to transparent for gradient
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
      backgroundColor: Colors.transparent, // Changed for gradient support
      foregroundColor: Colors.white,
      elevation: 4, // Remove shadow for cleaner gradient look
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

// Extension to add semantic gradient access to ThemeData
extension ThemeGradients on ThemeData {
  LinearGradient get scaffoldGradient => AppColors.scaffoldGradient;
  LinearGradient get primaryGradient => AppColors.headerFooterGradient;
  LinearGradient get accentGradient => AppColors.accentGradient;
  LinearGradient get surfaceGradient => AppColors.surfaceGradient;
  LinearGradient get cardGradient => AppColors.cardGradient;
  LinearGradient get previewGradient => AppColors.previewGradient;
  LinearGradient get headerFooterGradient => AppColors.headerFooterGradient;
}

// Helper widget to wrap Scaffold content with gradient background
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).scaffoldGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
