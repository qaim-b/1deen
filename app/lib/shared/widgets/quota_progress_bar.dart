import 'package:app/core/animation/app_durations.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class QuotaProgressBar extends StatelessWidget {
  const QuotaProgressBar({
    required this.label,
    required this.used,
    required this.cap,
    this.activeColor,
    super.key,
  });

  final String label;
  final int used;
  final int cap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = cap > 0 ? (used / cap).clamp(0.0, 1.0) : 0.0;
    final color = activeColor ?? theme.colorScheme.primary;
    final remaining = (cap - used).clamp(0, cap);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            Text(
              '$remaining left',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: reduceMotion ? Duration.zero : AppDurations.slow,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
