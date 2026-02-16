import 'package:app/core/theme/app_theme_mode.dart';

enum StrictnessMode {
  strict,
  soft,
  reminder,
}

extension StrictnessModeX on StrictnessMode {
  String get storageValue {
    switch (this) {
      case StrictnessMode.strict:
        return 'strict';
      case StrictnessMode.soft:
        return 'soft';
      case StrictnessMode.reminder:
        return 'reminder';
    }
  }

  static StrictnessMode fromStorage(String? value) {
    switch (value) {
      case 'strict':
        return StrictnessMode.strict;
      case 'reminder':
        return StrictnessMode.reminder;
      case 'soft':
      default:
        return StrictnessMode.soft;
    }
  }

  String get label {
    switch (this) {
      case StrictnessMode.strict:
        return 'Strict';
      case StrictnessMode.soft:
        return 'Soft';
      case StrictnessMode.reminder:
        return 'Reminder';
    }
  }
}

enum PrayerCalcMethod {
  muslimWorldLeague,
  northAmerica,
  ummAlQura,
}

extension PrayerCalcMethodX on PrayerCalcMethod {
  String get storageValue {
    switch (this) {
      case PrayerCalcMethod.muslimWorldLeague:
        return 'mwl';
      case PrayerCalcMethod.northAmerica:
        return 'isna';
      case PrayerCalcMethod.ummAlQura:
        return 'umm_al_qura';
    }
  }

  static PrayerCalcMethod fromStorage(String? value) {
    switch (value) {
      case 'isna':
        return PrayerCalcMethod.northAmerica;
      case 'umm_al_qura':
        return PrayerCalcMethod.ummAlQura;
      case 'mwl':
      default:
        return PrayerCalcMethod.muslimWorldLeague;
    }
  }

  String get label {
    switch (this) {
      case PrayerCalcMethod.muslimWorldLeague:
        return 'Muslim World League';
      case PrayerCalcMethod.northAmerica:
        return 'North America (ISNA)';
      case PrayerCalcMethod.ummAlQura:
        return 'Umm Al-Qura';
    }
  }
}

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.prayerCalcMethod,
    required this.strictnessMode,
    required this.lockBeforeMinutes,
    required this.lockAfterMinutes,
  });

  final AppThemeMode themeMode;
  final PrayerCalcMethod prayerCalcMethod;
  final StrictnessMode strictnessMode;
  final int lockBeforeMinutes;
  final int lockAfterMinutes;

  static const defaults = AppSettings(
    themeMode: AppThemeMode.calm,
    prayerCalcMethod: PrayerCalcMethod.muslimWorldLeague,
    strictnessMode: StrictnessMode.soft,
    lockBeforeMinutes: 15,
    lockAfterMinutes: 20,
  );

  AppSettings copyWith({
    AppThemeMode? themeMode,
    PrayerCalcMethod? prayerCalcMethod,
    StrictnessMode? strictnessMode,
    int? lockBeforeMinutes,
    int? lockAfterMinutes,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      prayerCalcMethod: prayerCalcMethod ?? this.prayerCalcMethod,
      strictnessMode: strictnessMode ?? this.strictnessMode,
      lockBeforeMinutes: lockBeforeMinutes ?? this.lockBeforeMinutes,
      lockAfterMinutes: lockAfterMinutes ?? this.lockAfterMinutes,
    );
  }
}
