import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/salah_guard/application/prayer_lock_window.dart';
import 'package:app/shared/widgets/countdown_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeroLockCard extends StatelessWidget {
  const HeroLockCard({
    required this.nextWindow,
    required this.timeFormat,
    required this.lockEngineHealthy,
    required this.loadingPrayerTimes,
    required this.syncingLock,
    required this.onRefreshTimes,
    required this.onSyncLock,
    super.key,
  });

  final PrayerLockWindow? nextWindow;
  final DateFormat timeFormat;
  final bool lockEngineHealthy;
  final bool loadingPrayerTimes;
  final bool syncingLock;
  final VoidCallback onRefreshTimes;
  final VoidCallback onSyncLock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppExtendedTheme>()!;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_moon_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Salah Focus', style: theme.textTheme.titleMedium),
                ),
                _EngineBadge(healthy: lockEngineHealthy, ext: ext),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (nextWindow != null) ...[
              Text('Next focus window', style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Text(nextWindow!.prayerName, style: theme.textTheme.displayLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${timeFormat.format(nextWindow!.startAt)} - ${timeFormat.format(nextWindow!.endAt)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              CountdownTimerWidget(
                targetTime: nextWindow!.startAt,
                prefix: 'in ',
                style: theme.textTheme.titleLarge,
              ),
            ] else
              Text(
                'Refresh prayer times to compute your next focus window.',
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: loadingPrayerTimes ? null : onRefreshTimes,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(loadingPrayerTimes ? 'Refreshing...' : 'Refresh times'),
                ),
                OutlinedButton.icon(
                  onPressed: syncingLock ? null : onSyncLock,
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(syncingLock ? 'Syncing...' : 'Sync lock'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineBadge extends StatelessWidget {
  const _EngineBadge({
    required this.healthy,
    required this.ext,
  });

  final bool healthy;
  final AppExtendedTheme ext;

  @override
  Widget build(BuildContext context) {
    final color = healthy ? ext.successColor : ext.dangerColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 9, color: color),
          const SizedBox(width: 6),
          Text(
            healthy ? 'Ready' : 'Needs setup',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

