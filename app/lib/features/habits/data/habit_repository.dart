import 'dart:convert';

import 'package:app/core/storage/app_preferences.dart';
import 'package:app/features/habits/domain/daily_habit.dart';

class HabitRepository {
  HabitRepository(this._preferences);

  final AppPreferences _preferences;

  static const _keyPrefix = 'habit.day.';

  DailyHabit loadDay(String dayKey) {
    final payload = _preferences.getString('$_keyPrefix$dayKey');
    if (payload == null) {
      return DailyHabit.empty(dayKey);
    }

    final map = jsonDecode(payload) as Map<String, dynamic>;
    return DailyHabit(
      dayKey: dayKey,
      prayedOnTime: map['prayedOnTime'] as bool? ?? false,
      avoidedScrollDuringLock: map['avoidedScrollDuringLock'] as bool? ?? false,
      streak: map['streak'] as int? ?? 0,
    );
  }

  Future<void> saveDay(DailyHabit habit) async {
    await _preferences.setString(
      '$_keyPrefix${habit.dayKey}',
      jsonEncode({
        'prayedOnTime': habit.prayedOnTime,
        'avoidedScrollDuringLock': habit.avoidedScrollDuringLock,
        'streak': habit.streak,
      }),
    );
  }
}
