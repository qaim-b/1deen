import 'package:app/core/theme/app_spacing.dart';
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
    if (conflicts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                const SizedBox(width: AppSpacing.sm),
                Text('Upcoming calendar conflict', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...conflicts.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '${c.title} at ${timeFormat.format(c.startAt)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

