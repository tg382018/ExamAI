import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF10B981); // Emerald
  static const darkBgColor = Color(0xFF021A12); // Deep Emerald/Black
  static const lightBgColor = Color(0xFFF9FAFB); // Gray 50

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBgColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: Color(0xFF059669),
        surface: Color(0xFF064E3B),
        onPrimary: Colors.black,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBgColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: Color(0xFF059669),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: Color(0xFF0F172A),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    );
  }
}
