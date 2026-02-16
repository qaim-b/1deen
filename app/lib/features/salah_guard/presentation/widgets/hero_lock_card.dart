import 'package:app/core/animation/app_durations.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/salah_guard/application/prayer_lock_window.dart';
import 'package:app/shared/widgets/animated_button.dart';
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
    final ext = Theme.of(context).extension<AppExtendedTheme>()!;
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.slow,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: AppRadii.borderXl,
          gradient: ext.heroGradient,
          boxShadow: AppShadows.elevated(theme.colorScheme.primary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_moon_rounded,
                  color: Colors.white.withAlpha(200),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Protect Your Salah',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (nextWindow != null) ...[
              Text(
                nextWindow!.prayerName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withAlpha(230),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: Colors.white.withAlpha(160)),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${timeFormat.format(nextWindow!.startAt)} — ${timeFormat.format(nextWindow!.endAt)}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              CountdownTimerWidget(
                targetTime: nextWindow!.startAt,
                prefix: 'Starts in  ',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ] else
              Text(
                'Tap refresh to compute your next lock window from your location.',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AnimatedButton(
                  onPressed: onRefreshTimes,
                  loading: loadingPrayerTimes,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(30),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Refresh times'),
                ),
                AnimatedButton(
                  onPressed: onSyncLock,
                  loading: syncingLock,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(30),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sync lock'),
                ),
                _StatusChip(healthy: lockEngineHealthy),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatefulWidget {
  const _StatusChip({required this.healthy});

  final bool healthy;

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.pulse,
    );
    if (widget.healthy) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.healthy && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.healthy) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppExtendedTheme>()!;
    final color = widget.healthy ? ext.successColor : ext.dangerColor;

    return Semantics(
      label: widget.healthy ? 'Lock engine is ready' : 'Lock engine needs permission',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: AppRadii.borderMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: widget.healthy
                  ? Tween<double>(begin: 0.6, end: 1.0).animate(
                      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                    )
                  : const AlwaysStoppedAnimation(1),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(100),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.healthy ? 'Engine ready' : 'Permission needed',
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
