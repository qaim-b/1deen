import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static TextStyle displayLarge({required bool isDark}) => GoogleFonts.dmSerifDisplay(
        fontWeight: FontWeight.w400,
        fontSize: isDark ? 48 : 44,
        height: 1.06,
      );

  static TextStyle headline({required bool isDark}) => GoogleFonts.dmSerifDisplay(
        fontWeight: FontWeight.w400,
        fontSize: isDark ? 36 : 34,
        height: 1.1,
      );

  static TextStyle titleLarge({required bool isDark}) => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 1.15,
      );

  static TextStyle titleMedium({required bool isDark}) => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        height: 1.2,
      );

  static TextStyle titleSmall({required bool isDark}) => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.2,
      );

  static TextStyle body({required bool isDark}) => GoogleFonts.inter(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w500,
      );

  static TextStyle bodySmall({required bool isDark}) => GoogleFonts.inter(
        fontSize: 14,
        height: 1.35,
      );

  static TextStyle caption({required bool isDark}) => GoogleFonts.inter(
        fontSize: 12,
        height: 1.3,
        letterSpacing: .2,
      );

  static TextStyle mono({required bool isDark}) => GoogleFonts.jetBrainsMono(
        fontSize: 36,
        height: 1.05,
        fontWeight: FontWeight.w600,
      );

  static TextStyle arabic() => const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 26,
        height: 1.6,
      );
}

