import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color accentBlue = Color(0xFF0288D1);
  static const Color deepBlue = Color(0xFF0D47A1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color softWhite = Color(0xFFF0F6FF);
  static const Color textDark = Color(0xFF0A1628);
  static const Color textGrey = Color(0xFF607D8B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: lightBlue,
        surface: white,
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryBlue),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
