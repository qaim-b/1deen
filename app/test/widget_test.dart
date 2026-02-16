import 'package:app/core/theme/app_theme_mode.dart';
import 'package:app/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default app settings stay in Stage 1 bounds', () {
    const defaults = AppSettings.defaults;
    expect(defaults.themeMode, AppThemeMode.calm);
    expect(defaults.lockBeforeMinutes, 15);
    expect(defaults.lockAfterMinutes, 20);
    expect(defaults.strictnessMode, StrictnessMode.soft);
  });
}
