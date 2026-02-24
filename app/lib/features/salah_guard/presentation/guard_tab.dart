import 'package:app/bootstrap/app_dependencies.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/calendar/domain/calendar_conflict.dart';
import 'package:app/features/prayer_times/domain/prayer_time_entry.dart';
import 'package:app/features/salah_guard/application/default_blocked_apps.dart';
import 'package:app/features/salah_guard/application/prayer_lock_window.dart';
import 'package:app/features/salah_guard/platform_bridge/lock_bridge.dart';
import 'package:app/features/salah_guard/presentation/widgets/conflict_banner.dart';
import 'package:app/features/salah_guard/presentation/widgets/hero_lock_card.dart';
import 'package:app/features/salah_guard/presentation/widgets/prayer_timeline.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/settings/domain/app_settings.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuardTab extends StatefulWidget {
  const GuardTab({
    required this.dependencies,
    required this.settingsController,
    super.key,
  });

  final AppDependencies dependencies;
  final SettingsController settingsController;

  @override
  State<GuardTab> createState() => _GuardTabState();
}

class _GuardTabState extends State<GuardTab> {
  final _timeFormat = DateFormat('h:mm a');

  bool _loadingPrayerTimes = false;
  bool _syncingLock = false;
  bool _lockEngineHealthy = false;
  String? _statusMessage;
  List<PrayerTimeEntry> _prayerTimes = const [];
  PrayerLockWindow? _nextWindow;
  List<CalendarConflict> _conflicts = const [];

  @override
  void initState() {
    super.initState();
    _refreshLockHealth();
  }

  Future<void> _refreshLockHealth() async {
    final healthy = await widget.dependencies.lockBridge.isEngineHealthy();
    if (!mounted) return;
    setState(() => _lockEngineHealthy = healthy);
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _loadingPrayerTimes = true;
      _statusMessage = null;
    });

    try {
      final position = await widget.dependencies.locationService
          .getCurrentPosition();
      final settings = widget.settingsController.settings;
      final times = widget.dependencies.prayerTimeService.getTodayPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        method: settings.prayerCalcMethod,
      );

      final nextWindow = widget.dependencies.lockWindowService.nextWindow(
        prayerTimes: times,
        lockBeforeMinutes: settings.lockBeforeMinutes,
        lockAfterMinutes: settings.lockAfterMinutes,
      );

      await _syncNativeSchedule(prayerTimes: times, settings: settings);

      var conflicts = const <CalendarConflict>[];
      if (nextWindow != null) {
        conflicts = await widget.dependencies.calendarConflictService
            .conflictsInNextMinutes(minutes: 30);
      }

      if (!mounted) return;
      setState(() {
        _prayerTimes = times;
        _nextWindow = nextWindow;
        _conflicts = conflicts;
        _statusMessage = conflicts.isNotEmpty
            ? 'Upcoming event conflicts with lock window.'
            : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Prayer load failed: $error');
    } finally {
      if (mounted) setState(() => _loadingPrayerTimes = false);
    }
  }

  Future<void> _syncLockConfiguration() async {
    setState(() {
      _syncingLock = true;
      _statusMessage = null;
    });

    final settings = widget.settingsController.settings;
    final synced = await widget.dependencies.lockBridge.syncConfiguration(
      strictnessMode: settings.strictnessMode,
      lockBeforeMinutes: settings.lockBeforeMinutes,
      lockAfterMinutes: settings.lockAfterMinutes,
    );
    final blockedSynced = await widget.dependencies.lockBridge.syncBlockedApps(
      defaultBlockedPackages,
    );
    var windowsSynced = true;
    if (_prayerTimes.isNotEmpty) {
      windowsSynced = await widget.dependencies.lockBridge.syncLockWindows(
        _buildLockWindowPayloads(_prayerTimes, settings),
      );
    }

    final healthy = await widget.dependencies.lockBridge.isEngineHealthy();

    if (!mounted) return;
    setState(() {
      _syncingLock = false;
      _lockEngineHealthy = healthy;
      _statusMessage = (synced && blockedSynced && windowsSynced)
          ? 'Lock configuration synced.'
          : 'Native sync failed.';
    });
  }

  Future<void> _syncNativeSchedule({
    required List<PrayerTimeEntry> prayerTimes,
    required AppSettings settings,
  }) async {
    await widget.dependencies.lockBridge.syncBlockedApps(
      defaultBlockedPackages,
    );
    await widget.dependencies.lockBridge.syncLockWindows(
      _buildLockWindowPayloads(prayerTimes, settings),
    );
  }

  List<LockWindowPayload> _buildLockWindowPayloads(
    List<PrayerTimeEntry> prayerTimes,
    AppSettings settings,
  ) {
    return prayerTimes
        .where((entry) => entry.name != 'Sunrise')
        .map(
          (entry) => LockWindowPayload(
            prayerName: entry.name,
            startAt: entry.time.subtract(
              Duration(minutes: settings.lockBeforeMinutes),
            ),
            endAt: entry.time.add(Duration(minutes: settings.lockAfterMinutes)),
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = widget.settingsController.settings;

    return GradientScaffold(
      child: ListView(
        padding: AppSpacing.pagePadding(context),
        children: [
          Text('Reflect', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Protect Salah windows and keep your focus rhythm steady.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          HeroLockCard(
            nextWindow: _nextWindow,
            timeFormat: _timeFormat,
            lockEngineHealthy: _lockEngineHealthy,
            loadingPrayerTimes: _loadingPrayerTimes,
            syncingLock: _syncingLock,
            onRefreshTimes: _loadPrayerTimes,
            onSyncLock: _syncLockConfiguration,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lock Strictness', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<StrictnessMode>(
                    segments: StrictnessMode.values
                        .map(
                          (mode) => ButtonSegment(
                            value: mode,
                            label: Text(mode.label),
                          ),
                        )
                        .toList(growable: false),
                    selected: {settings.strictnessMode},
                    onSelectionChanged: (value) async {
                      await widget.settingsController.updateStrictness(
                        value.first,
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Lock start before prayer: ${settings.lockBeforeMinutes} min',
                  ),
                  Slider(
                    value: settings.lockBeforeMinutes.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 25,
                    label: '${settings.lockBeforeMinutes}m',
                    onChanged: (v) async {
                      await widget.settingsController.updateLockBefore(
                        v.round(),
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                  Text(
                    'Lock end after adhan: ${settings.lockAfterMinutes} min',
                  ),
                  Slider(
                    value: settings.lockAfterMinutes.toDouble(),
                    min: 5,
                    max: 45,
                    divisions: 40,
                    label: '${settings.lockAfterMinutes}m',
                    onChanged: (v) async {
                      await widget.settingsController.updateLockAfter(
                        v.round(),
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
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
                    'Today\'s Prayer Times',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PrayerTimeline(
                    prayers: _prayerTimes,
                    timeFormat: _timeFormat,
                    nextWindow: _nextWindow,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ConflictBanner(conflicts: _conflicts, timeFormat: _timeFormat),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Focus Checklist', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _ChecklistRow(label: 'Accessibility permission enabled'),
                  _ChecklistRow(label: 'Overlay permission enabled'),
                  _ChecklistRow(
                    label:
                        'Blocked apps configured (${defaultBlockedPackages.length})',
                  ),
                  _ChecklistRow(label: 'Emergency unlock available (30s)'),
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
                    'Reflection Prompts',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _PromptRow(
                    prompt: 'What distracted me before the last prayer window?',
                  ),
                  _PromptRow(
                    prompt: 'One small change for stronger khushu tomorrow.',
                  ),
                  _PromptRow(
                    prompt: 'How can I protect Fajr from phone time tonight?',
                  ),
                ],
              ),
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding(context),
                child: Text(_statusMessage!, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _PromptRow extends StatelessWidget {
  const _PromptRow({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.onSurface.withAlpha(20)),
      ),
      child: Text(prompt, style: theme.textTheme.bodyMedium),
    );
  }
}
