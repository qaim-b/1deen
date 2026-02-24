import 'dart:async';
import 'dart:ui';

import 'package:app/bootstrap/app.dart';
import 'package:app/bootstrap/app_dependencies.dart';
import 'package:app/core/config/app_environment.dart';
import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/core/diagnostics/diagnostics_repository.dart';
import 'package:app/core/storage/app_preferences.dart';
import 'package:app/features/ai/application/ai_service.dart';
import 'package:app/features/ai/data/ai_usage_repository.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/calendar/application/calendar_conflict_service.dart';
import 'package:app/features/habits/application/habit_controller.dart';
import 'package:app/features/habits/data/habit_repository.dart';
import 'package:app/features/prayer_times/application/location_service.dart';
import 'package:app/features/prayer_times/application/prayer_time_service.dart';
import 'package:app/features/quran/data/quran_repository.dart';
import 'package:app/features/quran/data/quran_local_store.dart';
import 'package:app/features/salah_guard/application/lock_window_service.dart';
import 'package:app/features/salah_guard/platform_bridge/method_channel_lock_bridge.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/settings/data/settings_repository.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:app/features/subscription/data/subscription_repository.dart';
import 'package:app/features/subscription/platform/method_channel_subscription_purchase_bridge.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppEnvironment.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppEnvironment.supabaseUrl,
      anonKey: AppEnvironment.supabaseAnonKey,
    );
  }

  final appPreferences = await AppPreferences.create();
  final diagnosticsController = DiagnosticsController(
    DiagnosticsRepository(appPreferences),
  );
  await diagnosticsController.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      diagnosticsController.error(
        'flutter_error',
        details: {
          'exception': details.exceptionAsString(),
          'library': details.library,
        },
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      diagnosticsController.error(
        'platform_error',
        details: {
          'error': error.toString(),
          'stack': stack.toString(),
        },
      ),
    );
    return true;
  };

  final settingsController = SettingsController(SettingsRepository(appPreferences));
  final subscriptionController = SubscriptionController(
    SubscriptionRepository(appPreferences),
    MethodChannelSubscriptionPurchaseBridge(),
  );
  final authController = AuthController();

  await settingsController.initialize();
  await subscriptionController.initialize();
  await authController.initialize();

  final dependencies = AppDependencies(
    prayerTimeService: const PrayerTimeService(),
    locationService: LocationService(),
    lockBridge: MethodChannelLockBridge(),
    lockWindowService: const LockWindowService(),
    calendarConflictService: CalendarConflictService(),
    habitController: HabitController(HabitRepository(appPreferences)),
    quranRepository: QuranRepository(QuranLocalStore(appPreferences)),
    aiService: AiService(AiUsageRepository(appPreferences)),
  );

  runApp(
    OneDeenApp(
      settingsController: settingsController,
      subscriptionController: subscriptionController,
      authController: authController,
      diagnosticsController: diagnosticsController,
      dependencies: dependencies,
    ),
  );
}
