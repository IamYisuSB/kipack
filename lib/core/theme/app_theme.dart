import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const double radiusM = 16;
  static const double radiusL = 24;

  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceAlt: AppColors.surfaceLightAlt,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceAlt: AppColors.surfaceDarkAlt,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.primaryLight : AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.primary,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: textPrimary),
        headlineMedium: AppTextStyles.headline.copyWith(color: textPrimary),
        titleLarge: AppTextStyles.title.copyWith(color: textPrimary),
        titleMedium: AppTextStyles.subtitle.copyWith(color: textPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: textPrimary),
        bodySmall: AppTextStyles.caption.copyWith(color: textSecondary),
        labelLarge: AppTextStyles.button.copyWith(
          color: AppColors.backgroundLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: AppTextStyles.headline.copyWith(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        // Selected fill inverts by brightness: dark-green in light mode,
        // lime in dark mode — see AppColors.chipSelectedBackground. The
        // label/icon color is set per-chip at each call site (labelStyle
        // isn't selected-state-aware) via AppColors.chipSelectedForeground.
        selectedColor: isDark ? AppColors.accent : AppColors.primary,
        labelStyle: AppTextStyles.body.copyWith(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          foregroundColor: AppColors.backgroundLight,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          textStyle: AppTextStyles.button,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: textSecondary),
        labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(
            color: AppColors.secondaryIcon,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(
            color: AppColors.secondaryIcon,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.secondaryIcon,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
