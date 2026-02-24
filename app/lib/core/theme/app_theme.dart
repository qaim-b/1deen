import 'dart:ui';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_gradients.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme_mode.dart';
import 'package:app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension ThemeModeMapper on AppThemeMode {
  ThemeMode get materialThemeMode {
    switch (this) {
      case AppThemeMode.calm:
        return ThemeMode.light;
      case AppThemeMode.discipline:
        return ThemeMode.dark;
    }
  }
}

class AppExtendedTheme extends ThemeExtension<AppExtendedTheme> {
  const AppExtendedTheme({
    required this.pageGradient,
    required this.heroGradient,
    required this.glassGradient,
    required this.glassColor,
    required this.glassBorderColor,
    required this.glassSigma,
    required this.successColor,
    required this.dangerColor,
    required this.orbColor,
    required this.dividerColor,
    required this.isDark,
  });

  final LinearGradient pageGradient;
  final LinearGradient heroGradient;
  final LinearGradient glassGradient;
  final Color glassColor;
  final Color glassBorderColor;
  final double glassSigma;
  final Color successColor;
  final Color dangerColor;
  final Color orbColor;
  final Color dividerColor;
  final bool isDark;

  static AppExtendedTheme calm() => AppExtendedTheme(
        pageGradient: AppGradients.pageBackground(isDark: false),
        heroGradient: AppGradients.heroCard(isDark: false),
        glassGradient: AppGradients.glassFrost(isDark: false),
        glassColor: AppColors.calmGlassWhite,
        glassBorderColor: AppColors.calmGlassBorder,
        glassSigma: 10,
        successColor: AppColors.calmGreen,
        dangerColor: AppColors.calmRed,
        orbColor: AppColors.calmGold,
        dividerColor: AppColors.calmDivider,
        isDark: false,
      );

  static AppExtendedTheme discipline() => AppExtendedTheme(
        pageGradient: AppGradients.pageBackground(isDark: true),
        heroGradient: AppGradients.heroCard(isDark: true),
        glassGradient: AppGradients.glassFrost(isDark: true),
        glassColor: AppColors.disciplineGlassBlack,
        glassBorderColor: AppColors.disciplineGlassBorder,
        glassSigma: 12,
        successColor: AppColors.disciplineGreen,
        dangerColor: AppColors.disciplineRed,
        orbColor: AppColors.disciplineEmber,
        dividerColor: AppColors.disciplineDivider,
        isDark: true,
      );

  @override
  AppExtendedTheme copyWith({
    LinearGradient? pageGradient,
    LinearGradient? heroGradient,
    LinearGradient? glassGradient,
    Color? glassColor,
    Color? glassBorderColor,
    double? glassSigma,
    Color? successColor,
    Color? dangerColor,
    Color? orbColor,
    Color? dividerColor,
    bool? isDark,
  }) {
    return AppExtendedTheme(
      pageGradient: pageGradient ?? this.pageGradient,
      heroGradient: heroGradient ?? this.heroGradient,
      glassGradient: glassGradient ?? this.glassGradient,
      glassColor: glassColor ?? this.glassColor,
      glassBorderColor: glassBorderColor ?? this.glassBorderColor,
      glassSigma: glassSigma ?? this.glassSigma,
      successColor: successColor ?? this.successColor,
      dangerColor: dangerColor ?? this.dangerColor,
      orbColor: orbColor ?? this.orbColor,
      dividerColor: dividerColor ?? this.dividerColor,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppExtendedTheme lerp(covariant AppExtendedTheme? other, double t) {
    if (other == null) return this;
    return AppExtendedTheme(
      pageGradient: t < 0.5 ? pageGradient : other.pageGradient,
      heroGradient: t < 0.5 ? heroGradient : other.heroGradient,
      glassGradient: t < 0.5 ? glassGradient : other.glassGradient,
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      glassBorderColor: Color.lerp(glassBorderColor, other.glassBorderColor, t)!,
      glassSigma: lerpDouble(glassSigma, other.glassSigma, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      dangerColor: Color.lerp(dangerColor, other.dangerColor, t)!,
      orbColor: Color.lerp(orbColor, other.orbColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData light(AppThemeMode mode) {
    return mode == AppThemeMode.discipline ? _disciplineDark() : _calmLight();
  }

  static ThemeData dark(AppThemeMode mode) {
    return mode == AppThemeMode.discipline ? _disciplineDark() : _calmLight();
  }

  static ThemeData _calmLight() {
    const bg = AppColors.calmIvory;
    const surface = AppColors.calmSurface;
    const primary = AppColors.calmGold;

    final colorScheme = const ColorScheme.light(
      primary: primary,
      secondary: AppColors.calmGoldLight,
      surface: surface,
      error: AppColors.calmRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.calmTeal,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge(isDark: false),
      headlineSmall: AppTypography.headline(isDark: false),
      titleLarge: AppTypography.titleLarge(isDark: false),
      titleMedium: AppTypography.titleMedium(isDark: false),
      titleSmall: AppTypography.titleSmall(isDark: false),
      bodyLarge: AppTypography.body(isDark: false),
      bodyMedium: AppTypography.body(isDark: false),
      bodySmall: AppTypography.bodySmall(isDark: false),
      labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: bg.withAlpha(220),
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderLg,
          side: BorderSide(color: colorScheme.onSurface.withAlpha(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withAlpha(120)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(26)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          side: BorderSide(color: colorScheme.onSurface.withAlpha(40)),
          foregroundColor: colorScheme.onSurface,
          textStyle: textTheme.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          ),
          side: WidgetStateProperty.all(
            BorderSide(color: colorScheme.onSurface.withAlpha(30)),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withAlpha(170);
          }
          return colorScheme.onSurface.withAlpha(45);
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: colorScheme.onSurface.withAlpha(30),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.onSurface.withAlpha(18),
        thickness: .8,
      ),
      extensions: [AppExtendedTheme.calm()],
    );
  }

  static ThemeData _disciplineDark() {
    const bg = AppColors.disciplineCharcoal;
    const surface = AppColors.disciplineSlate;
    const primary = AppColors.disciplineEmber;

    final colorScheme = const ColorScheme.dark(
      primary: primary,
      secondary: AppColors.disciplineEmberLight,
      surface: surface,
      error: AppColors.disciplineRed,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Color(0xFFF2F2F2),
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge(isDark: true),
      headlineSmall: AppTypography.headline(isDark: true),
      titleLarge: AppTypography.titleLarge(isDark: true),
      titleMedium: AppTypography.titleMedium(isDark: true),
      titleSmall: AppTypography.titleSmall(isDark: true),
      bodyLarge: AppTypography.body(isDark: true),
      bodyMedium: AppTypography.body(isDark: true),
      bodySmall: AppTypography.bodySmall(isDark: true),
      labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: bg.withAlpha(228),
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderLg,
          side: BorderSide(color: Colors.white.withAlpha(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withAlpha(120)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: Colors.white.withAlpha(30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          side: BorderSide(color: Colors.white.withAlpha(38)),
          foregroundColor: colorScheme.onSurface,
          textStyle: textTheme.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          ),
          side: WidgetStateProperty.all(
            BorderSide(color: Colors.white.withAlpha(30)),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withAlpha(190);
          }
          return Colors.white.withAlpha(45);
        }),
        thumbColor: WidgetStateProperty.all(Colors.white),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: Colors.white.withAlpha(30),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withAlpha(18),
        thickness: .8,
      ),
      extensions: [AppExtendedTheme.discipline()],
    );
  }
}

