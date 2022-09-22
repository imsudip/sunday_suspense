import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyle {
  static String? get fontFamily => GoogleFonts.poppins().fontFamily;
  //static String? get fontFamily => GoogleFonts.yanoneKaffeesatz().fontFamily;

  // Google font
  static TextStyle get defaultFontStyle => GoogleFonts.poppins();

  // if we need to change a style

  // Headline 1
  static TextStyle get headline1 => GoogleFonts.poppins(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryColor,
      );
  // Headline 2
  static TextStyle get headline2 => GoogleFonts.poppins(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
      );
  // Headline 3
  static TextStyle get headline3 => GoogleFonts.poppins(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get subHeading => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3);
  // Bodytext 1
  static TextStyle get bodytext1 => GoogleFonts.poppins(
        fontSize: 16.0,
        color: Colors.white,
      );
  // Bodytext 2
  static TextStyle get bodytext2 => GoogleFonts.poppins(
        fontSize: 14.0,
        color: Colors.white60,
      );
  // Caption
  static TextStyle get caption =>
      GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.w400, color: AppColors.textSecondaryColor);
  static TextStyle get regular16 => GoogleFonts.poppins(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      );
  static TextTheme get textTheme => TextTheme(
        headline1: headline1,
        headline2: headline2,
        headline3: headline3,
        bodyText1: bodytext1,
        caption: caption,
      );
}
