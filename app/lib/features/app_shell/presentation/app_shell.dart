import 'package:app/bootstrap/app_dependencies.dart';
import 'package:app/core/animation/app_durations.dart';
import 'package:app/core/animation/page_route_transitions.dart';
import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/ai/presentation/ai_tab.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/habits/presentation/habits_tab.dart';
import 'package:app/features/home/presentation/home_tab.dart';
import 'package:app/features/quran/presentation/quran_tab.dart';
import 'package:app/features/salah_guard/application/guard_health_monitor.dart';
import 'package:app/features/salah_guard/application/prayer_schedule_automation.dart';
import 'package:app/features/salah_guard/presentation/guard_tab.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/settings/presentation/settings_tab.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:app/features/subscription/domain/subscription_tier.dart';
import 'package:app/shared/widgets/animated_nav_bar.dart';
import 'package:flutter/material.dart';

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
  int _tabIndex = 0;
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

  void _onTabChanged(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.settingsController,
        widget.subscriptionController,
        _guardHealthMonitor,
      ]),
      builder: (context, _) {
        final tabs = [
          HomeTab(
            onOpenGuard: () => _onTabChanged(1),
            onOpenHabits: () => _onTabChanged(2),
            onOpenQuran: () => _onTabChanged(3),
            onOpenAi: () => _onTabChanged(4),
            currentTier: widget.subscriptionController.tier,
            engineHealthy: _guardHealthMonitor.healthy,
            lastCheckedAt: _guardHealthMonitor.lastCheckedAt,
            engineDiagnostics: _guardHealthMonitor.engineDiagnostics,
          ),
          GuardTab(
            dependencies: widget.dependencies,
            settingsController: widget.settingsController,
          ),
          HabitsTab(
            habitController: widget.dependencies.habitController,
          ),
          QuranTab(
            quranRepository: widget.dependencies.quranRepository,
          ),
          AiTab(
            aiService: widget.dependencies.aiService,
            subscriptionController: widget.subscriptionController,
          ),
          SettingsTab(
            settingsController: widget.settingsController,
            subscriptionController: widget.subscriptionController,
            authController: widget.authController,
            diagnosticsController: widget.diagnosticsController,
          ),
        ];

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context),
          body: AnimatedSwitcher(
            duration: AppDurations.pageTransition,
            transitionBuilder: (child, animation) => TabFadeTransition(
              animation: animation,
              child: child,
            ),
            child: KeyedSubtree(
              key: ValueKey(_tabIndex),
              child: tabs[_tabIndex],
            ),
          ),
          bottomNavigationBar: AnimatedNavBar(
            selectedIndex: _tabIndex,
            onTap: _onTabChanged,
            items: const [
              NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              NavBarItem(
                icon: Icons.shield_moon_outlined,
                activeIcon: Icons.shield_moon,
                label: 'Guard',
              ),
              NavBarItem(
                icon: Icons.auto_graph_outlined,
                activeIcon: Icons.auto_graph,
                label: 'Habits',
              ),
              NavBarItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book_rounded,
                label: 'Quran',
              ),
              NavBarItem(
                icon: Icons.smart_toy_outlined,
                activeIcon: Icons.smart_toy,
                label: 'AI',
              ),
              NavBarItem(
                icon: Icons.tune_outlined,
                activeIcon: Icons.tune_rounded,
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium =
        widget.subscriptionController.tier == SubscriptionTier.premium;
    const titles = ['1Deen Home', 'Salah Guard', 'Habits', 'Quran', 'DeenLearner AI', 'Settings'];

    return AppBar(
      title: AnimatedSwitcher(
        duration: AppDurations.fast,
        child: Text(
          titles[_tabIndex],
          key: ValueKey(_tabIndex),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Center(
            child: AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Container(
                key: ValueKey(isPremium),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(isPremium ? 20 : 10),
                  borderRadius: AppRadii.borderSm,
                ),
                child: Text(
                  isPremium ? 'Premium' : 'Free',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
