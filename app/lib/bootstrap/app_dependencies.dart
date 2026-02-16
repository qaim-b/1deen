import 'package:app/features/ai/application/ai_service.dart';
import 'package:app/features/calendar/application/calendar_conflict_service.dart';
import 'package:app/features/habits/application/habit_controller.dart';
import 'package:app/features/prayer_times/application/location_service.dart';
import 'package:app/features/prayer_times/application/prayer_time_service.dart';
import 'package:app/features/quran/data/quran_repository.dart';
import 'package:app/features/salah_guard/application/lock_window_service.dart';
import 'package:app/features/salah_guard/platform_bridge/lock_bridge.dart';

class AppDependencies {
  const AppDependencies({
    required this.prayerTimeService,
    required this.locationService,
    required this.lockBridge,
    required this.lockWindowService,
    required this.calendarConflictService,
    required this.habitController,
    required this.quranRepository,
    required this.aiService,
  });

  final PrayerTimeService prayerTimeService;
  final LocationService locationService;
  final LockBridge lockBridge;
  final LockWindowService lockWindowService;
  final CalendarConflictService calendarConflictService;
  final HabitController habitController;
  final QuranRepository quranRepository;
  final AiService aiService;
}
