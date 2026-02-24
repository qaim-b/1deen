import 'package:app/core/theme/app_spacing.dart';
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
    final theme = Theme.of(context);
    if (prayers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          'Tap refresh to calculate prayer times.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: prayers
          .where((p) => p.name != 'Sunrise')
          .map((prayer) {
            final isActive = nextWindow?.prayerName == prayer.name;
            return _PrayerRow(
              prayer: prayer,
              isActive: isActive,
              timeFormat: timeFormat,
            );
          })
          .toList(growable: false),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.isActive,
    required this.timeFormat,
  });

  final PrayerTimeEntry prayer;
  final bool isActive;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary.withAlpha(10) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary.withAlpha(40)
              : theme.colorScheme.onSurface.withAlpha(10),
        ),
      ),
      child: ListTile(
        title: Text(
          prayer.name,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: isActive ? FontWeight.w700 : FontWeight.w600),
        ),
        subtitle: Text(
          _arabicName(prayer.name),
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 20,
            fontFamily: 'Amiri',
            color: theme.colorScheme.onSurface.withAlpha(140),
          ),
        ),
        trailing: Text(
          timeFormat.format(prayer.time),
          style: theme.textTheme.titleSmall?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _arabicName(String english) {
    switch (english) {
      case 'Fajr':
        return '?????';
      case 'Dhuhr':
        return '?????';
      case 'Asr':
        return '?????';
      case 'Maghrib':
        return '??????';
      case 'Isha':
        return '??????';
      default:
        return '';
    }
  }
}



