import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFAF0000);

  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    appBarTheme: AppBarTheme(backgroundColor: primaryColor, foregroundColor: Colors.white),
  );

  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark),
    scaffoldBackgroundColor: Colors.black,
    useMaterial3: true,
    appBarTheme: AppBarTheme(backgroundColor: primaryColor, foregroundColor: Colors.white),
  );
}
