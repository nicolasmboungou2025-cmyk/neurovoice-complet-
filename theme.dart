import 'package:flutter/material.dart';

class AppColors {
  static const Color background     = Color(0xFF0A0514);
  static const Color backgroundTop  = Color(0xFF1A0B2E);
  static const Color purple         = Color(0xFF9333EA);
  static const Color purpleLight    = Color(0xFFA855F7);
  static const Color purpleDark     = Color(0xFF3B0764);
  static const Color cardDark       = Color(0xFF121212);
  static const Color cardGlass      = Color(0xFF0F071B);
  static const Color borderPurple   = Color(0xFF3B2061);
  static const Color textGrey       = Color(0xFF9CA3AF);
  static const Color textWhite      = Color(0xFFFFFFFF);
  static const Color pink           = Color(0xFFEC4899);
  static const Color green          = Color(0xFF22C55E);
  static const Color red            = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      secondary: AppColors.purpleLight,
      surface: AppColors.cardGlass,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textWhite,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textWhite,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: AppColors.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textWhite,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textGrey,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      labelSmall: TextStyle(
        color: AppColors.textGrey,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontFamily: 'Poppins'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x55A855F7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x558B5CF6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.purpleLight, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}
