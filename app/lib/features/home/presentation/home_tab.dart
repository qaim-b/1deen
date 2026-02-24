import 'dart:ui';

import 'package:app/bootstrap/app_dependencies.dart';
import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme_mode.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/habits/domain/daily_habit.dart';
import 'package:app/features/prayer_times/domain/prayer_time_entry.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/settings/domain/app_settings.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:app/features/subscription/domain/subscription_tier.dart';
import 'package:app/shared/widgets/countdown_timer_widget.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:app/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    required this.dependencies,
    required this.settingsController,
    required this.authController,
    required this.diagnosticsController,
    required this.subscriptionController,
    required this.currentTier,
    required this.engineHealthy,
    required this.lastCheckedAt,
    required this.engineDiagnostics,
    required this.onOpenLearn,
    required this.onOpenQuran,
    required this.onOpenReflect,
    super.key,
  });

  final AppDependencies dependencies;
  final SettingsController settingsController;
  final AuthController authController;
  final DiagnosticsController diagnosticsController;
  final SubscriptionController subscriptionController;
  final SubscriptionTier currentTier;
  final bool engineHealthy;
  final DateTime? lastCheckedAt;
  final Map<String, dynamic> engineDiagnostics;
  final VoidCallback onOpenLearn;
  final VoidCallback onOpenQuran;
  final VoidCallback onOpenReflect;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _timeFormat = DateFormat('h:mm a');
  bool _loading = false;
  List<PrayerTimeEntry> _prayers = const [];
  late DailyHabit _todayHabit;

  PrayerTimeEntry? get _nextPrayer {
    final now = DateTime.now();
    for (final p in _prayers) {
      if (p.time.isAfter(now)) return p;
    }
    return _prayers.isNotEmpty ? _prayers.first : null;
  }

  double get _completionProgress {
    var count = 0;
    if (_todayHabit.prayedOnTime) count++;
    if (_todayHabit.avoidedScrollDuringLock) count++;
    return count / 2;
  }

  @override
  void initState() {
    super.initState();
    _todayHabit = widget.dependencies.habitController.loadToday();
    _load();
  }

  Future<void> _setPrayedOnTime(bool value) async {
    final next = await widget.dependencies.habitController.setPrayedOnTime(
      value,
    );
    if (!mounted) return;
    setState(() => _todayHabit = next);
  }

  Future<void> _setAvoidedScroll(bool value) async {
    final next = await widget.dependencies.habitController.setAvoidedScroll(
      value,
    );
    if (!mounted) return;
    setState(() => _todayHabit = next);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final pos = await widget.dependencies.locationService
          .getCurrentPosition();
      final settings = widget.settingsController.settings;
      final prayers = widget.dependencies.prayerTimeService.getTodayPrayerTimes(
        latitude: pos.latitude,
        longitude: pos.longitude,
        method: settings.prayerCalcMethod,
      );
      if (!mounted) return;
      setState(() => _prayers = prayers);
    } catch (_) {
      // keep UI responsive even if location is denied
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSettingsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _HomeSettingsSheet(
          settingsController: widget.settingsController,
          subscriptionController: widget.subscriptionController,
          authController: widget.authController,
          diagnosticsController: widget.diagnosticsController,
        );
      },
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextPrayer = _nextPrayer;

    return GradientScaffold(
      child: ListView(
        padding: AppSpacing.pagePadding(context),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1Deen',
                      style: GoogleFonts.playfairDisplay(
                        textStyle: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'created by Sara & Isa',
                      style: GoogleFonts.dmSans(
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(170),
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Settings',
                onPressed: _openSettingsSheet,
                icon: const Icon(Icons.settings_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _NextPrayerCard(
            nextPrayer: nextPrayer,
            loading: _loading,
            onRefresh: _load,
            prayers: _prayers,
            timeFormat: _timeFormat,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_clock_rounded),
              title: const Text('Lock Apps for Prayers'),
              subtitle: const Text(
                'Manage prayer focus lock and shield actions',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: widget.onOpenReflect,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProgressPanel(
            completionProgress: _completionProgress,
            habit: _todayHabit,
            onPrayedToggle: _setPrayedOnTime,
            onAvoidedScrollToggle: _setAvoidedScroll,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Access', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _quickActionChip(
                        context,
                        icon: Icons.school_rounded,
                        label: 'Learn',
                        onTap: widget.onOpenLearn,
                      ),
                      _quickActionChip(
                        context,
                        icon: Icons.menu_book_rounded,
                        label: 'Quran',
                        onTap: widget.onOpenQuran,
                      ),
                      _quickActionChip(
                        context,
                        icon: Icons.favorite_rounded,
                        label: 'Reflect',
                        onTap: widget.onOpenReflect,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week\'s Observances',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _bullet(theme, 'Friday prayer and khutbah preparation'),
                  _bullet(theme, 'Daily streak consistency check'),
                  _bullet(theme, 'Quran reflection block after Isha'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Qibla Compass', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withAlpha(20),
                          ),
                        ),
                        child: Icon(
                          Icons.explore_rounded,
                          color: theme.colorScheme.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Text(
                          'Compass module is in progress. You can continue with Quran and prayer scheduling offline.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _quickActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      side: BorderSide(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
      ),
    );
  }

  Widget _bullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Icon(
              Icons.circle,
              size: 7,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({
    required this.nextPrayer,
    required this.loading,
    required this.onRefresh,
    required this.prayers,
    required this.timeFormat,
  });

  final PrayerTimeEntry? nextPrayer;
  final bool loading;
  final VoidCallback onRefresh;
  final List<PrayerTimeEntry> prayers;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'NEXT PRAYER',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              nextPrayer?.name ?? '--',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (nextPrayer != null)
              CountdownTimerWidget(
                targetTime: nextPrayer!.time,
                prefix: 'in ',
                style: theme.textTheme.displaySmall,
              )
            else
              Text(
                'Tap refresh to load prayer times',
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: loading ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(loading ? 'Refreshing...' : 'Refresh times'),
            ),
            const SizedBox(height: AppSpacing.md),
            _PrayerList(prayers: prayers, timeFormat: timeFormat),
          ],
        ),
      ),
    );
  }
}

class _PrayerList extends StatelessWidget {
  const _PrayerList({required this.prayers, required this.timeFormat});

  final List<PrayerTimeEntry> prayers;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final now = DateTime.now();

    return Column(
      children: prayers
          .where((p) => p.name != 'Sunrise')
          .map((p) {
            final isNext =
                p.time.isAfter(now) &&
                prayers
                        .where((item) => item.name != 'Sunrise')
                        .firstWhere(
                          (item) => item.time.isAfter(now),
                          orElse: () => prayers.first,
                        ) ==
                    p;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isNext
                    ? theme.colorScheme.primary.withAlpha(12)
                    : theme.colorScheme.surface,
              ),
              child: ListTile(
                dense: true,
                title: Text(p.name),
                subtitle: Text(
                  _arabic(p.name),
                  style: const TextStyle(fontFamily: 'Amiri'),
                ),
                trailing: Text(timeFormat.format(p.time)),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  String _arabic(String name) {
    switch (name) {
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

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.completionProgress,
    required this.habit,
    required this.onPrayedToggle,
    required this.onAvoidedScrollToggle,
  });

  final double completionProgress;
  final DailyHabit habit;
  final ValueChanged<bool> onPrayedToggle;
  final ValueChanged<bool> onAvoidedScrollToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                ProgressRing(
                  progress: completionProgress,
                  size: 78,
                  strokeWidth: 8,
                  child: Text('${(completionProgress * 100).round()}%'),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    'Current streak: ${habit.streak} days',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              value: habit.prayedOnTime,
              onChanged: onPrayedToggle,
              title: const Text('Prayed on time'),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: habit.avoidedScrollDuringLock,
              onChanged: onAvoidedScrollToggle,
              title: const Text('Avoided scroll during lock'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSettingsSheet extends StatelessWidget {
  const _HomeSettingsSheet({
    required this.settingsController,
    required this.subscriptionController,
    required this.authController,
    required this.diagnosticsController,
  });

  final SettingsController settingsController;
  final SubscriptionController subscriptionController;
  final AuthController authController;
  final DiagnosticsController diagnosticsController;

  @override
  Widget build(BuildContext context) {
    final settings = settingsController.settings;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              color: theme.colorScheme.surface,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withAlpha(40),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Settings',
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: SwitchListTile(
                      value: settings.themeMode == AppThemeMode.discipline,
                      onChanged: (v) => settingsController.updateThemeMode(
                        v ? AppThemeMode.discipline : AppThemeMode.calm,
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        settings.themeMode == AppThemeMode.discipline
                            ? 'Enabled'
                            : 'Disabled',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.public_rounded),
                      title: const Text('Prayer Calculation Method'),
                      subtitle: Text(settings.prayerCalcMethod.label),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<PrayerCalcMethod>(
                          value: settings.prayerCalcMethod,
                          items: PrayerCalcMethod.values
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              settingsController.updatePrayerMethod(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.workspace_premium_rounded),
                      title: const Text('Subscription'),
                      subtitle: Text(
                        'Current tier: ${subscriptionController.tier.label}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (authController.enabled)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person_rounded),
                        title: Text(
                          authController.user?.email ?? 'No active session',
                        ),
                        trailing: OutlinedButton(
                          onPressed: authController.processing
                              ? null
                              : authController.signOut,
                          child: const Text('Sign out'),
                        ),
                      ),
                    ),
                  if (authController.enabled) const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.health_and_safety_rounded),
                      title: const Text('Diagnostics'),
                      subtitle: Text(
                        'Recent events: ${diagnosticsController.events.length}',
                      ),
                      trailing: TextButton(
                        onPressed: diagnosticsController.clear,
                        child: const Text('Clear'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
