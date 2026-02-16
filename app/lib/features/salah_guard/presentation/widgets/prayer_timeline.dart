import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/prayer_times/domain/prayer_time_entry.dart';
import 'package:app/features/salah_guard/application/prayer_lock_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerTimeline extends StatelessWidget {
  const PrayerTimeline({
    required this.prayers,
    required this.timeFormat,
    this.nextWindow,
    super.key,
  });

  final List<PrayerTimeEntry> prayers;
  final DateFormat timeFormat;
  final PrayerLockWindow? nextWindow;

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          'Tap "Refresh times" to calculate today\'s schedule.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
        ),
      );
    }

    return Column(
      children: List.generate(prayers.length, (index) {
        final prayer = prayers[index];
        final isNext = nextWindow?.prayerName == prayer.name;
        final isPast = prayer.time.isBefore(DateTime.now());

        return _PrayerTimelineRow(
          prayer: prayer,
          timeFormat: timeFormat,
          isNext: isNext,
          isPast: isPast && !isNext,
          isLast: index == prayers.length - 1,
          index: index,
          total: prayers.length,
        );
      }),
    );
  }
}

class _PrayerTimelineRow extends StatelessWidget {
  const _PrayerTimelineRow({
    required this.prayer,
    required this.timeFormat,
    required this.isNext,
    required this.isPast,
    required this.isLast,
    required this.index,
    required this.total,
  });

  final PrayerTimeEntry prayer;
  final DateFormat timeFormat;
  final bool isNext;
  final bool isPast;
  final bool isLast;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = Theme.of(context).extension<AppExtendedTheme>()!;
    final primaryColor = theme.colorScheme.primary;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final dotColor = isNext
        ? primaryColor
        : isPast
            ? ext.successColor
            : theme.colorScheme.onSurface.withAlpha(60);

    final textColor = isNext
        ? theme.colorScheme.onSurface
        : isPast
            ? theme.colorScheme.onSurface.withAlpha(120)
            : theme.colorScheme.onSurface.withAlpha(180);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduceMotion
          ? Duration.zero
          : Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Timeline rail
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  // Dot
                  Container(
                    width: isNext ? 14 : 10,
                    height: isNext ? 14 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isNext ? dotColor : (isPast ? dotColor : Colors.transparent),
                      border: Border.all(color: dotColor, width: 2),
                      boxShadow: isNext
                          ? [BoxShadow(color: dotColor.withAlpha(80), blurRadius: 8)]
                          : null,
                    ),
                  ),
                  // Line
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: theme.colorScheme.onSurface.withAlpha(30),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prayer.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: textColor,
                              fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                          if (isNext)
                            Text(
                              'Next prayer',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: primaryColor.withAlpha(180),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      timeFormat.format(prayer.time),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
