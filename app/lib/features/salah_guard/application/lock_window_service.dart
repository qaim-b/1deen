import 'package:app/features/prayer_times/domain/prayer_time_entry.dart';
import 'package:app/features/salah_guard/application/prayer_lock_window.dart';

class LockWindowService {
  const LockWindowService();

  PrayerLockWindow? nextWindow({
    required List<PrayerTimeEntry> prayerTimes,
    required int lockBeforeMinutes,
    required int lockAfterMinutes,
  }) {
    final now = DateTime.now();

    for (final prayer in prayerTimes.where((p) => p.name != 'Sunrise')) {
      final start = prayer.time.subtract(Duration(minutes: lockBeforeMinutes));
      final end = prayer.time.add(Duration(minutes: lockAfterMinutes));
      if (end.isAfter(now)) {
        return PrayerLockWindow(prayerName: prayer.name, startAt: start, endAt: end);
      }
    }

    return null;
  }
}
