import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      fontFamily: 'Muli',
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        surface: Colors.grey[850],
      ),
      fontFamily: 'Muli',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
      ),
    );
  }
}