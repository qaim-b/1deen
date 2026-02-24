import 'package:app/core/animation/app_durations.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

class AnimatedPanel extends StatelessWidget {
  const AnimatedPanel({
    required this.title,
    required this.child,
    this.icon,
    this.action,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final duration = reduceMotion ? Duration.zero : AppDurations.normal;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: AppSpacing.cardPaddingLegacy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: title, icon: icon, action: action),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}


