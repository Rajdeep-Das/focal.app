import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.indigo,
      scaffoldBackgroundColor: Colors.black,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Colors.indigo,
        secondary: Colors.indigoAccent,
        surface: Color(0xFF121212),
      ),
    );
  }
}
