import 'package:app/features/habits/data/habit_repository.dart';
import 'package:app/features/habits/domain/daily_habit.dart';
import 'package:intl/intl.dart';

class HabitController {
  HabitController(this._repository);

  final HabitRepository _repository;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  DailyHabit loadToday() {
    return _repository.loadDay(_dayKey(DateTime.now()));
  }

  Future<DailyHabit> setPrayedOnTime(bool value) async {
    final current = loadToday();
    final streak = value ? _calculateStreakFromYesterday() + 1 : 0;
    final next = current.copyWith(prayedOnTime: value, streak: streak);
    await _repository.saveDay(next);
    return next;
  }

  Future<DailyHabit> setAvoidedScroll(bool value) async {
    final current = loadToday();
    final next = current.copyWith(avoidedScrollDuringLock: value);
    await _repository.saveDay(next);
    return next;
  }

  int _calculateStreakFromYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayHabit = _repository.loadDay(_dayKey(yesterday));
    return yesterdayHabit.prayedOnTime ? yesterdayHabit.streak : 0;
  }

  String _dayKey(DateTime date) => _dateFormat.format(date);
}
