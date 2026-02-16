import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static TextStyle displayLarge({bool isDark = false}) => isDark
      ? GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, fontSize: 32, height: 1.2)
      : GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 32, height: 1.2);

  static TextStyle headline({bool isDark = false}) => isDark
      ? GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 24, height: 1.25)
      : GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 24, height: 1.25);

  static TextStyle titleLarge({bool isDark = false}) => isDark
      ? GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 20, height: 1.3)
      : GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 20, height: 1.3);

  static TextStyle titleMedium({bool isDark = false}) => isDark
      ? GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 18, height: 1.3)
      : GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 18, height: 1.3);

  static TextStyle titleSmall({bool isDark = false}) => isDark
      ? GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 16, height: 1.3)
      : GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 16, height: 1.3);

  static TextStyle body({bool isDark = false}) =>
      GoogleFonts.ibmPlexSans(fontSize: 15, height: 1.45);

  static TextStyle bodySmall({bool isDark = false}) =>
      GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.4);

  static TextStyle caption({bool isDark = false}) =>
      GoogleFonts.ibmPlexSans(fontSize: 12, height: 1.3, fontWeight: FontWeight.w500);

  static TextStyle label({bool isDark = false}) =>
      GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.35, fontWeight: FontWeight.w600);

  static TextStyle mono({bool isDark = false}) =>
      GoogleFonts.ibmPlexMono(fontSize: 28, fontWeight: FontWeight.w700, height: 1.1);

  static TextStyle arabic() => const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 22,
        height: 1.8,
        letterSpacing: 0.5,
      );

  static TextStyle navLabel({bool isDark = false}) => isDark
      ? GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 12)
      : GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 12);
}
