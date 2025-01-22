import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF6B7FD7),
      scaffoldBackgroundColor: const Color(0xFF121417),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: Colors.white.withOpacity(0.87),
        displayColor: Colors.white,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6B7FD7),
        secondary: Color(0xFF8E9FFF),
        surface: Color(0xFF1E2126),
        background: Color(0xFF121417),
        onSurface: Colors.white,
        error: Color(0xFFFF6B6B),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        color: const Color(0xFF1E2126),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: const Color(0xFF4B5EAB),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4B5EAB),
        secondary: Color(0xFF6B7FD7),
        surface: Colors.white,
        onSurface: Color(0xFF1A1B1E),
        error: Color(0xFFDC3545),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        color: Colors.white,
      ),
    );
  }
}
