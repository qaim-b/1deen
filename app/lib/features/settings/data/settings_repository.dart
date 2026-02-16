import 'package:app/core/storage/app_preferences.dart';
import 'package:app/core/theme/app_theme_mode.dart';
import 'package:app/features/settings/domain/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._preferences);

  final AppPreferences _preferences;

  static const _keyThemeMode = 'settings.theme_mode';
  static const _keyPrayerMethod = 'settings.prayer_method';
  static const _keyStrictness = 'settings.strictness';
  static const _keyLockBefore = 'settings.lock_before';
  static const _keyLockAfter = 'settings.lock_after';

  AppSettings load() {
    final theme = AppThemeModeX.fromStorage(_preferences.getString(_keyThemeMode));
    final prayerMethod = PrayerCalcMethodX.fromStorage(_preferences.getString(_keyPrayerMethod));
    final strictness = StrictnessModeX.fromStorage(_preferences.getString(_keyStrictness));

    return AppSettings.defaults.copyWith(
      themeMode: theme,
      prayerCalcMethod: prayerMethod,
      strictnessMode: strictness,
      lockBeforeMinutes: _preferences.getInt(_keyLockBefore),
      lockAfterMinutes: _preferences.getInt(_keyLockAfter),
    );
  }

  Future<void> save(AppSettings settings) async {
    await Future.wait([
      _preferences.setString(_keyThemeMode, settings.themeMode.storageValue),
      _preferences.setString(_keyPrayerMethod, settings.prayerCalcMethod.storageValue),
      _preferences.setString(_keyStrictness, settings.strictnessMode.storageValue),
      _preferences.setInt(_keyLockBefore, settings.lockBeforeMinutes),
      _preferences.setInt(_keyLockAfter, settings.lockAfterMinutes),
    ]);
  }
}
