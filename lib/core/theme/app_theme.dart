import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette
  static const Color beigeLight = Color(0xFFF7F5F0);
  static const Color warmWhite = Color(0xFFFFFFFF);
  static const Color darkBrown = Color(0xFF3D2E24);
  static const Color softBlack = Color(0xFF1C1A17);
  static const Color progressGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFE67E22);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color lightGray = Color(0xFFE2DFD5);

  // Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: darkBrown,
      scaffoldBackgroundColor: beigeLight,
      colorScheme: const ColorScheme.light(
        primary: darkBrown,
        onPrimary: warmWhite,
        secondary: progressGreen,
        onSecondary: warmWhite,
        surface: warmWhite,
        onSurface: softBlack,
        background: beigeLight,
        onBackground: softBlack,
        error: Colors.redAccent,
      ),
      dividerColor: lightGray,
      cardTheme: CardTheme(
        color: warmWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightGray, width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: softBlack,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: softBlack,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: softBlack,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: softBlack.withOpacity(0.8),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkBrown,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warmWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBrown, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown,
          foregroundColor: warmWhite,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: warmWhite,
      scaffoldBackgroundColor: softBlack,
      colorScheme: const ColorScheme.dark(
        primary: warmWhite,
        onPrimary: softBlack,
        secondary: progressGreen,
        onSecondary: warmWhite,
        surface: Color(0xFF262421),
        onSurface: warmWhite,
        background: softBlack,
        onBackground: warmWhite,
        error: Colors.redAccent,
      ),
      dividerColor: const Color(0xFF383531),
      cardTheme: CardTheme(
        color: const Color(0xFF262421),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF383531), width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: warmWhite,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: warmWhite,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: warmWhite,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: warmWhite.withOpacity(0.8),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: warmWhite,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF262421),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF383531), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF383531), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warmWhite, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warmWhite,
          foregroundColor: softBlack,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
