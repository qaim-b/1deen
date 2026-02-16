enum AppThemeMode {
  calm,
  discipline,
}

extension AppThemeModeX on AppThemeMode {
  String get storageValue {
    switch (this) {
      case AppThemeMode.calm:
        return 'calm';
      case AppThemeMode.discipline:
        return 'discipline';
    }
  }

  static AppThemeMode fromStorage(String? value) {
    switch (value) {
      case 'discipline':
        return AppThemeMode.discipline;
      case 'calm':
      default:
        return AppThemeMode.calm;
    }
  }

  String get displayName {
    switch (this) {
      case AppThemeMode.calm:
        return 'Calm';
      case AppThemeMode.discipline:
        return 'Discipline';
    }
  }
}
