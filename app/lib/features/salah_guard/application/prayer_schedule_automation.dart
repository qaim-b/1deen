import 'dart:async';

import 'package:app/features/prayer_times/application/location_service.dart';
import 'package:app/features/prayer_times/application/prayer_time_service.dart';
import 'package:app/features/prayer_times/domain/prayer_time_entry.dart';
import 'package:app/features/salah_guard/application/default_blocked_apps.dart';
import 'package:app/features/salah_guard/platform_bridge/lock_bridge.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/settings/domain/app_settings.dart';
import 'package:flutter/widgets.dart';

class PrayerScheduleAutomation with WidgetsBindingObserver {
  PrayerScheduleAutomation({
    required PrayerTimeService prayerTimeService,
    required LocationService locationService,
    required LockBridge lockBridge,
    required SettingsController settingsController,
  })  : _prayerTimeService = prayerTimeService,
        _locationService = locationService,
        _lockBridge = lockBridge,
        _settingsController = settingsController;

  final PrayerTimeService _prayerTimeService;
  final LocationService _locationService;
  final LockBridge _lockBridge;
  final SettingsController _settingsController;

  Timer? _midnightTimer;
  DateTime? _lastSyncedAt;
  Duration? _lastTimeZoneOffset;
  String? _lastTimeZoneName;
  bool _runningSync = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _settingsController.addListener(_onSettingsChanged);
    unawaited(_lockBridge.requestIosAuthorization());
    unawaited(_lockBridge.scheduleAutomation());
    unawaited(_sync(reason: 'startup', force: true));
    _scheduleMidnightTick();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsController.removeListener(_onSettingsChanged);
    _midnightTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_onResumed());
    }
  }

  void _onSettingsChanged() {
    unawaited(_sync(reason: 'settings_changed', force: true));
  }

  Future<void> _onResumed() async {
    final consumeResyncFlag = await _lockBridge.consumeResyncRequired();
    await _sync(reason: consumeResyncFlag ? 'native_resync_flag' : 'resume');
  }

  Future<void> _sync({required String reason, bool force = false}) async {
    if (_runningSync) {
      return;
    }

    final now = DateTime.now();
    final dayChanged = _lastSyncedAt == null || !_isSameDay(_lastSyncedAt!, now);
    final zoneOffsetChanged = _lastTimeZoneOffset != now.timeZoneOffset;
    final zoneNameChanged = _lastTimeZoneName != now.timeZoneName;

    if (!force && !dayChanged && !zoneOffsetChanged && !zoneNameChanged) {
      return;
    }

    _runningSync = true;
    try {
      final position = await _locationService.getCurrentPosition();
      final settings = _settingsController.settings;

      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final todayTimes = _prayerTimeService.getPrayerTimesForDate(
        date: today,
        latitude: position.latitude,
        longitude: position.longitude,
        method: settings.prayerCalcMethod,
      );
      final tomorrowTimes = _prayerTimeService.getPrayerTimesForDate(
        date: tomorrow,
        latitude: position.latitude,
        longitude: position.longitude,
        method: settings.prayerCalcMethod,
      );

      final windows = [
        ..._buildLockWindowPayloads(todayTimes, settings),
        ..._buildLockWindowPayloads(tomorrowTimes, settings),
      ];

      await _lockBridge.syncConfiguration(
        strictnessMode: settings.strictnessMode,
        lockBeforeMinutes: settings.lockBeforeMinutes,
        lockAfterMinutes: settings.lockAfterMinutes,
      );
      await _lockBridge.syncBlockedApps(defaultBlockedPackages);
      await _lockBridge.syncLockWindows(windows);

      _lastSyncedAt = now;
      _lastTimeZoneOffset = now.timeZoneOffset;
      _lastTimeZoneName = now.timeZoneName;
    } catch (_) {
      // Automation should stay best-effort and never crash the UI layer.
    } finally {
      _runningSync = false;
      _scheduleMidnightTick();
    }
  }

  void _scheduleMidnightTick() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 1);
    final delay = nextMidnight.difference(now);

    _midnightTimer = Timer(delay, () {
      unawaited(_sync(reason: 'midnight_rollover', force: true));
    });
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
            startAt: entry.time.subtract(Duration(minutes: settings.lockBeforeMinutes)),
            endAt: entry.time.add(Duration(minutes: settings.lockAfterMinutes)),
          ),
        )
        .toList(growable: false);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
