import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized type scale. Manrope gives the app a modern, geometric,
/// slightly editorial feel that reads as premium rather than default Material.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base(
    double size,
    FontWeight weight, {
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle display = _base(
    32,
    FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.15,
  );
  static TextStyle headline = _base(
    24,
    FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );
  static TextStyle title = _base(18, FontWeight.w700, height: 1.3);
  static TextStyle subtitle = _base(15, FontWeight.w600, height: 1.3);
  static TextStyle body = _base(14, FontWeight.w500, height: 1.4);
  static TextStyle bodyStrong = _base(14, FontWeight.w700, height: 1.4);
  static TextStyle caption = _base(
    12,
    FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
  );
  static TextStyle button = _base(15, FontWeight.w700, letterSpacing: 0.1);
}
