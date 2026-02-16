import 'package:app/core/storage/app_preferences.dart';
import 'package:app/features/ai/domain/ai_usage_snapshot.dart';

class AiUsageRepository {
  AiUsageRepository(this._preferences);

  final AppPreferences _preferences;

  static const _freeDateKey = 'ai.usage.free.day_key';
  static const _freeCountKey = 'ai.usage.free.count';
  static const _premiumMonthKey = 'ai.usage.premium.month_key';
  static const _premiumCountKey = 'ai.usage.premium.count';

  AiUsageSnapshot load({required String dayKey, required String monthKey}) {
    final currentDayKey = _preferences.getString(_freeDateKey);
    final currentMonthKey = _preferences.getString(_premiumMonthKey);

    final freeUsed = currentDayKey == dayKey ? (_preferences.getInt(_freeCountKey) ?? 0) : 0;
    final premiumUsed = currentMonthKey == monthKey ? (_preferences.getInt(_premiumCountKey) ?? 0) : 0;

    return AiUsageSnapshot(
      freeUsedToday: freeUsed,
      freeDailyCap: 3,
      premiumUsedMonth: premiumUsed,
      premiumMonthlyCap: 150,
    );
  }

  Future<void> incrementFree({required String dayKey}) async {
    final snap = load(dayKey: dayKey, monthKey: _preferences.getString(_premiumMonthKey) ?? '');
    await _preferences.setString(_freeDateKey, dayKey);
    await _preferences.setInt(_freeCountKey, snap.freeUsedToday + 1);
  }

  Future<void> incrementPremium({required String monthKey}) async {
    final dayKey = _preferences.getString(_freeDateKey) ?? '';
    final snap = load(dayKey: dayKey, monthKey: monthKey);
    await _preferences.setString(_premiumMonthKey, monthKey);
    await _preferences.setInt(_premiumCountKey, snap.premiumUsedMonth + 1);
  }
}
