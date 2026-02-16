class DailyHabit {
  const DailyHabit({
    required this.dayKey,
    required this.prayedOnTime,
    required this.avoidedScrollDuringLock,
    required this.streak,
  });

  final String dayKey;
  final bool prayedOnTime;
  final bool avoidedScrollDuringLock;
  final int streak;

  static DailyHabit empty(String dayKey) {
    return DailyHabit(
      dayKey: dayKey,
      prayedOnTime: false,
      avoidedScrollDuringLock: false,
      streak: 0,
    );
  }

  DailyHabit copyWith({
    bool? prayedOnTime,
    bool? avoidedScrollDuringLock,
    int? streak,
  }) {
    return DailyHabit(
      dayKey: dayKey,
      prayedOnTime: prayedOnTime ?? this.prayedOnTime,
      avoidedScrollDuringLock: avoidedScrollDuringLock ?? this.avoidedScrollDuringLock,
      streak: streak ?? this.streak,
    );
  }
}
