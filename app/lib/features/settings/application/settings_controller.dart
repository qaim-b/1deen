import 'package:app/core/theme/app_theme_mode.dart';
import 'package:app/features/settings/data/settings_repository.dart';
import 'package:app/features/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final SettingsRepository _repository;
  AppSettings _settings = AppSettings.defaults;

  AppSettings get settings => _settings;

  Future<void> initialize() async {
    _settings = _repository.load();
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    await _update(_settings.copyWith(themeMode: mode));
  }

  Future<void> updatePrayerMethod(PrayerCalcMethod prayerCalcMethod) async {
    await _update(_settings.copyWith(prayerCalcMethod: prayerCalcMethod));
  }

  Future<void> updateStrictness(StrictnessMode strictnessMode) async {
    await _update(_settings.copyWith(strictnessMode: strictnessMode));
  }

  Future<void> updateLockBefore(int minutes) async {
    await _update(_settings.copyWith(lockBeforeMinutes: minutes));
  }

  Future<void> updateLockAfter(int minutes) async {
    await _update(_settings.copyWith(lockAfterMinutes: minutes));
  }

  Future<void> _update(AppSettings next) async {
    _settings = next;
    notifyListeners();
    await _repository.save(next);
  }
}
