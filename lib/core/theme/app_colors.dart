import 'package:flutter/material.dart';

/// Kipack color palette — deep forest green as the anchor color with a
/// vivid lime accent, on a warm cream background. Matches the "tru"
/// travel-app reference the user provided (dark green + chartreuse lime +
/// off-white), not hand-picked.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF132A1D);
  static const Color primaryLight = Color(0xFF3E7A54);
  static const Color accent = Color(0xFFC6E83E);
  static const Color accentSoft = Color(0xFFEAF7C0);

  // Light theme surfaces
  static const Color backgroundLight = Color(0xFFECF2E8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightAlt = Color(0xFFE9E6DC);

  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF0B1710);
  static const Color surfaceDark = Color(0xFF132A1D);
  static const Color surfaceDarkAlt = Color(0xFF1D3B28);

  // Text
  static const Color textPrimaryLight = Color(0xFF16241C);
  static const Color textSecondaryLight = Color(0xFF6B7A70);
  static const Color textPrimaryDark = Color(0xFFF0EDE4);
  static const Color textSecondaryDark = Color(0xFF9CB3A3);

  // Semantic
  static const Color success = Color(0xFF6FB98F);
  static const Color error = Color(0xFFE0685A);

  // Secondary icons, dividers, input borders
  static const Color secondaryIcon = Color(0xFFA9BFAE);

  // Map: country manually marked as visited (no trip attached)
  static const Color mapManualVisited = Color(0xFF5B8DEF);

  // Category accents (per-icon tint, warm-to-cool spread)
  static const Color catClothing = Color(0xFF8C7AE6);
  static const Color catToiletries = Color(0xFF5FB8B0);
  static const Color catElectronics = Color(0xFF5B8DEF);
  static const Color catDocuments = Color(0xFFE0A458);
  static const Color catMisc = Color(0xFFDB7E9E);

  /// Selected chip fill: dark-green in light mode, lime in dark mode
  /// (inverted so the lime accent doesn't disappear against dark surfaces).
  static Color chipSelectedBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? accent : primary;

  /// Selected chip label/icon color — always the opposite of
  /// [chipSelectedBackground] so it stays legible against it.
  static Color chipSelectedForeground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primary : accent;
}
