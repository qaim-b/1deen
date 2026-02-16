import 'package:adhan_dart/adhan_dart.dart';
import 'package:app/features/prayer_times/domain/prayer_time_entry.dart';
import 'package:app/features/settings/domain/app_settings.dart';

class PrayerTimeService {
  const PrayerTimeService();

  List<PrayerTimeEntry> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
    required PrayerCalcMethod method,
  }) {
    return getPrayerTimesForDate(
      date: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      method: method,
    );
  }

  List<PrayerTimeEntry> getPrayerTimesForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required PrayerCalcMethod method,
  }) {
    // adhan_dart expects the calendar date anchor, not current wall-clock time.
    final anchorDate = DateTime(date.year, date.month, date.day);
    final coordinates = Coordinates(latitude, longitude);
    final params = _buildParams(method);
    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: anchorDate,
      calculationParameters: params,
      precision: true,
    );

    return [
      PrayerTimeEntry(name: 'Fajr', time: prayerTimes.fajr.toLocal()),
      PrayerTimeEntry(name: 'Sunrise', time: prayerTimes.sunrise.toLocal()),
      PrayerTimeEntry(name: 'Dhuhr', time: prayerTimes.dhuhr.toLocal()),
      PrayerTimeEntry(name: 'Asr', time: prayerTimes.asr.toLocal()),
      PrayerTimeEntry(name: 'Maghrib', time: prayerTimes.maghrib.toLocal()),
      PrayerTimeEntry(name: 'Isha', time: prayerTimes.isha.toLocal()),
    ];
  }

  CalculationParameters _buildParams(PrayerCalcMethod method) {
    switch (method) {
      case PrayerCalcMethod.northAmerica:
        return CalculationMethodParameters.northAmerica();
      case PrayerCalcMethod.ummAlQura:
        return CalculationMethodParameters.ummAlQura();
      case PrayerCalcMethod.muslimWorldLeague:
        return CalculationMethodParameters.muslimWorldLeague();
    }
  }
}
