import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontal = width < 600
        ? 18.0
        : width < 1024
            ? 24.0
            : 32.0;
    final top = width < 600 ? 96.0 : 104.0;
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, 20);
  }

  static const pagePaddingLegacy = EdgeInsets.fromLTRB(18, 96, 18, 20);
  static const cardPaddingLegacy = EdgeInsets.all(18);

  static EdgeInsets cardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final value = width < 600
        ? 16.0
        : width < 1024
            ? 18.0
            : 20.0;
    return EdgeInsets.all(value);
  }
}

class AppRadii {
  const AppRadii._();

  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 30;
  static const double full = 999;

  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderXl = BorderRadius.circular(xl);
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> soft() => const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> elevated() => const [
        BoxShadow(
          color: Color(0x18000000),
          blurRadius: 28,
          offset: Offset(0, 10),
        ),
      ];
}

