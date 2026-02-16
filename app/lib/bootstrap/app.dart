import 'package:app/bootstrap/app_dependencies.dart';
import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/app_shell/presentation/app_shell.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/auth/presentation/auth_screen.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:flutter/material.dart';

class OneDeenApp extends StatelessWidget {
  const OneDeenApp({
    required this.settingsController,
    required this.subscriptionController,
    required this.authController,
    required this.diagnosticsController,
    required this.dependencies,
    super.key,
  });

  final SettingsController settingsController;
  final SubscriptionController subscriptionController;
  final AuthController authController;
  final DiagnosticsController diagnosticsController;
  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        settingsController,
        subscriptionController,
        authController,
      ]),
      builder: (context, _) {
        final hasAuth = authController.enabled;
        final ready = !hasAuth || authController.initialized;
        final showShell = !hasAuth || authController.isSignedIn;

        return MaterialApp(
          title: '1Deen',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(settingsController.settings.themeMode),
          darkTheme: AppTheme.dark(settingsController.settings.themeMode),
          themeMode: settingsController.settings.themeMode.materialThemeMode,
          home: !ready
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : showShell
                  ? AppShell(
                      settingsController: settingsController,
                      subscriptionController: subscriptionController,
                      authController: authController,
                      diagnosticsController: diagnosticsController,
                      dependencies: dependencies,
                    )
                  : AuthScreen(authController: authController),
        );
      },
    );
  }
}
