import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF9a0e13);
  static const Color accentColor = Color(0xFF282828);
  static const Color backgroundColor = Color(0xFF111111);
  static const Color textPrimaryColor = Color(0xFFffffff);
  static const Color textSecondaryColor = Color(0xFF6A6969);
  static const Color primaryWhiteColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color.fromARGB(255, 255, 150, 150);

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  static ColorScheme lightScheme = const ColorScheme.light(
    primary: primaryColor,
    secondary: accentColor,
  );

  static ColorScheme darkScheme = const ColorScheme.dark(
    primary: primaryColor,
    secondary: accentColor,
  );
}
