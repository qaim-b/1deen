import 'dart:ui';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_gradients.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme_mode.dart';
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
        glassSigma: 12,
        successColor: AppColors.calmGreen,
        dangerColor: AppColors.calmRed,
        orbColor: AppColors.calmTeal,
        dividerColor: AppColors.calmDivider,
        isDark: false,
      );

  static AppExtendedTheme discipline() => AppExtendedTheme(
        pageGradient: AppGradients.pageBackground(isDark: true),
        heroGradient: AppGradients.heroCard(isDark: true),
        glassGradient: AppGradients.glassFrost(isDark: true),
        glassColor: AppColors.disciplineGlassBlack,
        glassBorderColor: AppColors.disciplineGlassBorder,
        glassSigma: 16,
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
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.calmTeal,
      surface: AppColors.calmIvory,
      primary: AppColors.calmTeal,
      secondary: AppColors.calmGold,
    );

    final textTheme = GoogleFonts.sourceSans3TextTheme().copyWith(
      headlineSmall: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.w500,
        fontSize: 40,
        height: 1.12,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, fontSize: 28, height: 1.2),
      titleMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, fontSize: 22, height: 1.25),
      titleSmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, fontSize: 18, height: 1.3),
      bodyLarge: GoogleFonts.sourceSans3(fontSize: 17, height: 1.72, fontWeight: FontWeight.w400, letterSpacing: 0.12),
      bodyMedium: GoogleFonts.sourceSans3(fontSize: 16, height: 1.72, fontWeight: FontWeight.w400, letterSpacing: 0.1),
      bodySmall: GoogleFonts.sourceSans3(fontSize: 13, height: 1.6, letterSpacing: 0.08),
      labelLarge: GoogleFonts.sourceSans3(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.25),
      labelMedium: GoogleFonts.ibmPlexMono(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.4),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.calmIvory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.calmIvory.withAlpha(220),
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.calmTeal,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w600,
          fontSize: 24,
          color: AppColors.calmTeal,
          letterSpacing: -0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.calmSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: AppColors.calmSand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: AppColors.calmSand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: AppColors.calmTeal, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.calmSurface,
        elevation: 0,
        shadowColor: Colors.black.withAlpha(18),
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: AppColors.calmTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: AppColors.calmTeal,
          side: const BorderSide(color: AppColors.calmTeal),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.calmTeal,
        thumbColor: AppColors.calmTeal,
        overlayColor: AppColors.calmTeal.withAlpha(30),
        inactiveTrackColor: AppColors.calmSand,
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.calmTeal;
          return AppColors.calmSand;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.calmTeal.withAlpha(80);
          return AppColors.calmSand.withAlpha(80);
        }),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.calmNavBar,
        indicatorColor: AppColors.calmNavIndicator,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 1.2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.calmDivider,
        thickness: 1,
      ),
      extensions: [AppExtendedTheme.calm()],
    );
  }

  static ThemeData _disciplineDark() {
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.disciplineEmber,
      surface: AppColors.disciplineCharcoal,
      primary: AppColors.disciplineEmber,
      secondary: AppColors.disciplineMint,
    );

    final textTheme = GoogleFonts.outfitTextTheme().copyWith(
      headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 27, height: 1.15),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 22),
      titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
      titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
      bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 15, height: 1.4, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.4),
      bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.35),
      labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
      labelMedium: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.disciplineCharcoal,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.disciplineCharcoal.withAlpha(230),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: AppColors.disciplineEmber,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.disciplineSlate,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: AppColors.disciplineBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: AppColors.disciplineBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: AppColors.disciplineEmber, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.disciplineSlate,
        elevation: 0,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          backgroundColor: AppColors.disciplineEmber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withAlpha(45)),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.disciplineEmber,
        thumbColor: AppColors.disciplineEmber,
        overlayColor: AppColors.disciplineEmber.withAlpha(30),
        inactiveTrackColor: AppColors.disciplineBorder,
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.disciplineEmber;
          return AppColors.disciplineBorder;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.disciplineEmber.withAlpha(80);
          return AppColors.disciplineBorder.withAlpha(80);
        }),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.disciplineNavBar,
        indicatorColor: AppColors.disciplineNavIndicator,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.disciplineDivider,
        thickness: 1,
      ),
      extensions: [AppExtendedTheme.discipline()],
    );
  }
}
