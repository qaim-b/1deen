import 'package:flutter/material.dart';

mixin StaggeredListAnimation<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController staggerController;

  void initStagger({Duration duration = const Duration(milliseconds: 800)}) {
    staggerController = AnimationController(vsync: this, duration: duration)
      ..forward();
  }

  Animation<double> staggeredOpacity(int index, int total) {
    if (total <= 0) return const AlwaysStoppedAnimation(1);
    final start = (index / total) * 0.6;
    final end = start + 0.4;
    return CurvedAnimation(
      parent: staggerController,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );
  }

  Animation<Offset> staggeredSlide(int index, int total) {
    if (total <= 0) return const AlwaysStoppedAnimation(Offset.zero);
    final start = (index / total) * 0.6;
    final end = start + 0.4;
    return Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: staggerController,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void disposeStagger() {
    staggerController.dispose();
  }
}
