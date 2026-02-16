import 'package:app/core/theme/app_spacing.dart';
import 'package:app/shared/widgets/streak_flame_icon.dart';
import 'package:flutter/material.dart';

class StreakDisplay extends StatelessWidget {
  const StreakDisplay({required this.streak, super.key});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreakFlameIcon(
          active: streak > 0,
          size: 36,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$streak',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              streak == 1 ? 'day streak' : 'day streak',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
