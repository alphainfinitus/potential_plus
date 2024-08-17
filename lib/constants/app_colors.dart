import 'package:flutter/material.dart';

// Usage: AppColors.getColor("primary_button_color")
class AppColors {
  static const Map<String, Color> colors = {
    "seed": Colors.deepPurple, // Deep Purple color
  };

  static Color getColor(String key) {
    return colors[key] ?? Colors.transparent; // Fallback to transparent if key not found
  }
}