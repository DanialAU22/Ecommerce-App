import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class AppTextStyles {
  static TextTheme textTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color baseColor = isDark ? const Color(0xFFF2F5FF) : const Color(0xFF1A1C2C);

    return GoogleFonts.interTextTheme(
      TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: baseColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: baseColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: baseColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: baseColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: baseColor.withValues(alpha: 0.85),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: baseColor.withValues(alpha: 0.7),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          color: baseColor,
        ),
      ),
    );
  }
}