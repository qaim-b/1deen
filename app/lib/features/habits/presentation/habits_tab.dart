import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/habits/application/habit_controller.dart';
import 'package:app/features/habits/domain/daily_habit.dart';
import 'package:app/features/habits/presentation/widgets/habit_toggle_row.dart';
import 'package:app/features/habits/presentation/widgets/streak_display.dart';
import 'package:app/shared/widgets/animated_panel.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:app/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitsTab extends StatefulWidget {
  const HabitsTab({required this.habitController, super.key});

  final HabitController habitController;

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  final _dayFormat = DateFormat('EEEE, MMM d');
  late DailyHabit _todayHabit;

  @override
  void initState() {
    super.initState();
    _todayHabit = widget.habitController.loadToday();
  }

  double get _completionProgress {
    var count = 0;
    if (_todayHabit.prayedOnTime) count++;
    if (_todayHabit.avoidedScrollDuringLock) count++;
    return count / 2;
  }

  Future<void> _setPrayedOnTime(bool value) async {
    final next = await widget.habitController.setPrayedOnTime(value);
    if (!mounted) return;
    setState(() => _todayHabit = next);
  }

  Future<void> _setAvoidedScroll(bool value) async {
    final next = await widget.habitController.setAvoidedScroll(value);
    if (!mounted) return;
    setState(() => _todayHabit = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = _dayFormat.format(DateTime.now());

    return GradientScaffold(
      child: ListView(
        padding: AppSpacing.pagePadding(context),
        children: [
          // Overview card with progress ring
          AnimatedPanel(
            title: 'Daily Progress',
            icon: Icons.auto_graph_rounded,
            child: Row(
              children: [
                ProgressRing(
                  progress: _completionProgress,
                  size: 80,
                  strokeWidth: 8,
                  child: Text(
                    '${(_completionProgress * 100).round()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        today,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _completionProgress >= 1
                            ? 'All tasks complete!'
                            : 'Keep going, you\'re doing great.',
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Streak display
          AnimatedPanel(
            title: 'Streak',
            icon: Icons.local_fire_department_rounded,
            child: Center(
              child: StreakDisplay(streak: _todayHabit.streak),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Habit toggles
          AnimatedPanel(
            title: 'Today\'s Habits',
            icon: Icons.check_circle_outline_rounded,
            child: Column(
              children: [
                HabitToggleRow(
                  label: 'Prayed on time',
                  value: _todayHabit.prayedOnTime,
                  onChanged: _setPrayedOnTime,
                  icon: Icons.mosque_rounded,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withAlpha(20),
                ),
                HabitToggleRow(
                  label: 'Avoided scroll during lock',
                  value: _todayHabit.avoidedScrollDuringLock,
                  onChanged: _setAvoidedScroll,
                  icon: Icons.phone_locked_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


