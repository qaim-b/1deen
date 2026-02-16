import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 48;

  static const double pageHorizontal = 20;
  static const double pageTop = 16;

  static const pagePadding = EdgeInsets.fromLTRB(20, 100, 20, 20);
  static const cardPadding = EdgeInsets.all(20);
  static const sectionGap = SizedBox(height: 16);
  static const cardGap = SizedBox(height: 14);
}

class AppRadii {
  const AppRadii._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 28;
  static const double full = 999;

  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderXl = BorderRadius.circular(xl);
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> soft(Color color) => [
        BoxShadow(
          color: color.withAlpha(20),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> elevated(Color color) => [
        BoxShadow(
          color: color.withAlpha(38),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withAlpha(51),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
}
