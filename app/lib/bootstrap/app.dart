import 'dart:async';

import 'package:app/bootstrap/app_dependencies.dart';
import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/app_shell/presentation/app_shell.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/auth/presentation/auth_screen.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              : _StartupGate(
                  showShell: showShell,
                  shellBuilder: (_) => AppShell(
                    settingsController: settingsController,
                    subscriptionController: subscriptionController,
                    authController: authController,
                    diagnosticsController: diagnosticsController,
                    dependencies: dependencies,
                  ),
                  authBuilder: (_) =>
                      AuthScreen(authController: authController),
                ),
        );
      },
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate({
    required this.showShell,
    required this.shellBuilder,
    required this.authBuilder,
  });

  final bool showShell;
  final WidgetBuilder shellBuilder;
  final WidgetBuilder authBuilder;

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1650), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.showShell
        ? widget.shellBuilder(context)
        : widget.authBuilder(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      child: _showSplash ? const _BrandSplash() : target,
    );
  }
}

class _BrandSplash extends StatefulWidget {
  const _BrandSplash();

  @override
  State<_BrandSplash> createState() => _BrandSplashState();
}

class _BrandSplashState extends State<_BrandSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bgStart = dark ? const Color(0xFF10151B) : const Color(0xFFF7FAFF);
    final bgEnd = dark ? const Color(0xFF1B232E) : const Color(0xFFEAF3FF);
    final titleColor = dark ? Colors.white : const Color(0xFF121A25);
    final subtitleColor = dark ? Colors.white70 : const Color(0xFF4E5C6E);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mosque_rounded,
                    color: Color(0xFF73E0B9),
                    size: 56,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '1Deen',
                    style: GoogleFonts.playfairDisplay(
                      textStyle: TextStyle(
                        color: titleColor,
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'created by Sara & Isa',
                    style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                        color: subtitleColor,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
