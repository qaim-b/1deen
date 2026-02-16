import 'package:app/core/animation/app_durations.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/calendar/domain/calendar_conflict.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConflictBanner extends StatelessWidget {
  const ConflictBanner({
    required this.conflicts,
    required this.timeFormat,
    super.key,
  });

  final List<CalendarConflict> conflicts;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppExtendedTheme>()!;
    final theme = Theme.of(context);

    return AnimatedSize(
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
      child: conflicts.isEmpty
          ? const SizedBox.shrink()
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppDurations.normal,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -8 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: ext.dangerColor.withAlpha(15),
                  borderRadius: AppRadii.borderLg,
                  border: Border.all(color: ext.dangerColor.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: ext.dangerColor,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Calendar Conflicts',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: ext.dangerColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...conflicts.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${c.title} at ${timeFormat.format(c.startAt)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
