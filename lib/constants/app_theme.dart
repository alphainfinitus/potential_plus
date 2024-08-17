import 'package:flutter/material.dart';

class AppTheme {
  // Define your light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.deepPurple,
    brightness: Brightness.light,
    // Define more properties as needed
  );

  // Define your dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.grey[900],
    brightness: Brightness.dark,
    // Define more properties as needed
  );

  // more themes if needed
}