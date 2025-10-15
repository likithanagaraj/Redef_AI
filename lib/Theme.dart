import 'package:flutter/material.dart';

// ---------------- Colors ----------------
class AppColors {
  static const primary = Color(0xFF59B74F);
  static const secondary = Color(0xFF014E3C);
  static const white = Colors.white;
  static const black = Colors.black;
  static const background = Color(0xFFF1EDE7);
}

// ---------------- Fonts ----------------
class AppFonts {
  static const primaryFont = 'SourceSerif4';
  static const seconderFont = 'Inter';

  static TextStyle heading1 = const TextStyle(
    fontFamily: primaryFont,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: seconderFont,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle button = const TextStyle(
    fontFamily: seconderFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle body = const TextStyle(
    fontFamily: seconderFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
}

// ---------------- Spacing ----------------
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 40.0;
}
