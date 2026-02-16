import 'package:flutter/animation.dart';

class AppCurves {
  const AppCurves._();

  static const emphasized = Curves.easeOutCubic;
  static const spring = Curves.elasticOut;
  static const decelerate = Curves.decelerate;
  static const subtle = Curves.easeInOut;
  static const bounce = Curves.bounceOut;
}
