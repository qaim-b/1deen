import 'package:app/features/calendar/domain/calendar_conflict.dart';
import 'package:device_calendar/device_calendar.dart';

class CalendarConflictService {
  CalendarConflictService({DeviceCalendarPlugin? plugin}) : _plugin = plugin ?? DeviceCalendarPlugin();

  final DeviceCalendarPlugin _plugin;

  Future<List<CalendarConflict>> conflictsInNextMinutes({required int minutes}) async {
    final permissions = await _plugin.hasPermissions();
    if (!(permissions.data ?? false)) {
      final requested = await _plugin.requestPermissions();
      if (!(requested.data ?? false)) {
        return const [];
      }
    }

    final calendars = await _plugin.retrieveCalendars();
    final now = DateTime.now();
    final end = now.add(Duration(minutes: minutes));

    final conflicts = <CalendarConflict>[];

    for (final calendar in calendars.data ?? const <Calendar>[]) {
      if (calendar.id == null) {
        continue;
      }
      final eventsResult = await _plugin.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(startDate: now, endDate: end),
      );

      for (final event in eventsResult.data ?? const <Event>[]) {
        if (event.start == null || event.end == null) {
          continue;
        }
        conflicts.add(
          CalendarConflict(
            title: event.title ?? 'Calendar Event',
            startAt: event.start!,
            endAt: event.end!,
          ),
        );
      }
    }

    return conflicts;
  }
}
