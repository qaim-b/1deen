import 'package:app/features/settings/domain/app_settings.dart';

class LockWindowPayload {
  const LockWindowPayload({
    required this.prayerName,
    required this.startAt,
    required this.endAt,
  });

  final String prayerName;
  final DateTime startAt;
  final DateTime endAt;

  Map<String, dynamic> toJson() {
    return {
      'prayerName': prayerName,
      'startEpochMillis': startAt.millisecondsSinceEpoch,
      'endEpochMillis': endAt.millisecondsSinceEpoch,
    };
  }
}

abstract class LockBridge {
  Future<bool> syncConfiguration({
    required StrictnessMode strictnessMode,
    required int lockBeforeMinutes,
    required int lockAfterMinutes,
  });

  Future<bool> syncLockWindows(List<LockWindowPayload> windows);

  Future<bool> syncBlockedApps(List<String> packageNames);

  Future<bool> requestEmergencyUnlock({int durationSeconds = 30});

  Future<bool> requestIosAuthorization();

  Future<bool> scheduleAutomation();

  Future<bool> consumeResyncRequired();

  Future<bool> isEngineHealthy();

  Future<Map<String, dynamic>> getEngineDiagnostics();
}
