import 'package:app/bootstrap/app_dependencies.dart';
import 'package:app/core/animation/page_route_transitions.dart';
import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/home/presentation/home_tab.dart';
import 'package:app/features/learn/presentation/learn_tab.dart';
import 'package:app/features/quran/presentation/quran_hub_tab.dart';
import 'package:app/features/salah_guard/application/guard_health_monitor.dart';
import 'package:app/features/salah_guard/application/prayer_schedule_automation.dart';
import 'package:app/features/salah_guard/presentation/guard_tab.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:app/shared/widgets/animated_nav_bar.dart';
import 'package:flutter/material.dart';

enum AppMainTab { home, learn, quran, reflect }

class AppShell extends StatefulWidget {
  const AppShell({
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
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppMainTab _tab = AppMainTab.home;
  late final PrayerScheduleAutomation _prayerScheduleAutomation;
  late final GuardHealthMonitor _guardHealthMonitor;

  @override
  void initState() {
    super.initState();
    _prayerScheduleAutomation = PrayerScheduleAutomation(
      prayerTimeService: widget.dependencies.prayerTimeService,
      locationService: widget.dependencies.locationService,
      lockBridge: widget.dependencies.lockBridge,
      settingsController: widget.settingsController,
    );
    _guardHealthMonitor = GuardHealthMonitor(
      lockBridge: widget.dependencies.lockBridge,
      diagnosticsController: widget.diagnosticsController,
    );
    _prayerScheduleAutomation.start();
    _guardHealthMonitor.start();
  }

  @override
  void dispose() {
    _prayerScheduleAutomation.dispose();
    _guardHealthMonitor.disposeMonitor();
    super.dispose();
  }

  void _onTabChanged(AppMainTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
  }

  void _openTab(AppMainTab tab) => _onTabChanged(tab);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.settingsController,
        widget.subscriptionController,
        _guardHealthMonitor,
      ]),
      builder: (context, _) {
        final tabViews = <AppMainTab, Widget>{
          AppMainTab.home: HomeTab(
            dependencies: widget.dependencies,
            settingsController: widget.settingsController,
            authController: widget.authController,
            diagnosticsController: widget.diagnosticsController,
            subscriptionController: widget.subscriptionController,
            currentTier: widget.subscriptionController.tier,
            engineHealthy: _guardHealthMonitor.healthy,
            lastCheckedAt: _guardHealthMonitor.lastCheckedAt,
            engineDiagnostics: _guardHealthMonitor.engineDiagnostics,
            onOpenLearn: () => _openTab(AppMainTab.learn),
            onOpenQuran: () => _openTab(AppMainTab.quran),
            onOpenReflect: () => _openTab(AppMainTab.reflect),
          ),
          AppMainTab.learn: LearnTab(
            aiService: widget.dependencies.aiService,
            subscriptionController: widget.subscriptionController,
          ),
          AppMainTab.quran: QuranHubTab(
            repository: widget.dependencies.quranRepository,
          ),
          AppMainTab.reflect: GuardTab(
            dependencies: widget.dependencies,
            settingsController: widget.settingsController,
          ),
        };

        final tabsOrder = AppMainTab.values;
        final selectedIndex = tabsOrder.indexOf(_tab);

        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) =>
                TabFadeTransition(animation: animation, child: child),
            child: KeyedSubtree(key: ValueKey(_tab), child: tabViews[_tab]!),
          ),
          bottomNavigationBar: AnimatedNavBar(
            selectedIndex: selectedIndex,
            onTap: (index) => _onTabChanged(tabsOrder[index]),
            items: const [
              NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              NavBarItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school_rounded,
                label: 'Learn',
              ),
              NavBarItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book_rounded,
                label: 'Quran',
              ),
              NavBarItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite_rounded,
                label: 'Reflect',
              ),
            ],
          ),
        );
      },
    );
  }
}
