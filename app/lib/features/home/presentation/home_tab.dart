import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/subscription/domain/subscription_tier.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    required this.onOpenGuard,
    required this.onOpenHabits,
    required this.onOpenQuran,
    required this.onOpenAi,
    required this.currentTier,
    required this.engineHealthy,
    required this.lastCheckedAt,
    required this.engineDiagnostics,
    super.key,
  });

  final VoidCallback onOpenGuard;
  final VoidCallback onOpenHabits;
  final VoidCallback onOpenQuran;
  final VoidCallback onOpenAi;
  final SubscriptionTier currentTier;
  final bool engineHealthy;
  final DateTime? lastCheckedAt;
  final Map<String, dynamic> engineDiagnostics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _Reveal(
            delayMs: 0,
            child: _HeroPanel(
              tier: currentTier,
              healthy: engineHealthy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Reveal(
            delayMs: 70,
            child: _ReliabilityCard(
              engineHealthy: engineHealthy,
              lastCheckedAt: lastCheckedAt,
              engineDiagnostics: engineDiagnostics,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Reveal(
            delayMs: 120,
            child: Text('Quick Actions', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          _Reveal(
            delayMs: 170,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.18,
              children: [
                _ShortcutCard(
                  icon: Icons.shield_moon_rounded,
                  title: 'Salah Guard',
                  subtitle: 'Focus mode',
                  color: theme.colorScheme.primary,
                  onTap: onOpenGuard,
                ),
                _ShortcutCard(
                  icon: Icons.show_chart_rounded,
                  title: 'Habits',
                  subtitle: 'Streak tracking',
                  color: const Color(0xFF2FA37C),
                  onTap: onOpenHabits,
                ),
                _ShortcutCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Quran',
                  subtitle: 'Daily recitation',
                  color: const Color(0xFFCCA34C),
                  onTap: onOpenQuran,
                ),
                _ShortcutCard(
                  icon: Icons.smart_toy_rounded,
                  title: 'DeenLearner AI',
                  subtitle: 'Ask concise',
                  color: const Color(0xFF5A94E0),
                  onTap: onOpenAi,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Reveal(
            delayMs: 220,
            child: Builder(builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final primary = Theme.of(context).colorScheme.primary;
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1520) : Colors.white,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(
                    color: primary.withAlpha(isDark ? 50 : 40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 30 : 8),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primary.withAlpha(isDark ? 40 : 28),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(Icons.tips_and_updates_rounded, color: primary, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Best results: keep Guard strict during study/work blocks.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? Colors.white.withAlpha(200)
                                  : const Color(0xFF111827).withAlpha(200),
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.tier, required this.healthy});

  final SubscriptionTier tier;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Color.lerp(const Color(0xFF0F1520), primary, 0.18)!,
                  Color.lerp(const Color(0xFF080C10), primary, 0.06)!,
                ]
              : [
                  Color.lerp(Colors.white, primary, 0.10)!,
                  Color.lerp(const Color(0xFFEEF2FF), primary, 0.04)!,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: primary.withAlpha(isDark ? 55 : 45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withAlpha(isDark ? 30 : 20),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assalamu Alaikum',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? Colors.white : const Color(0xFF0D1117),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Protect your salah and your attention.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: (isDark ? Colors.white : const Color(0xFF0D1117)).withAlpha(170),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatusChip(
                label: healthy ? 'Guard active' : 'Guard needs attention',
                color: healthy ? const Color(0xFF2FA37C) : theme.colorScheme.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusChip(
                label: tier == SubscriptionTier.premium ? 'Premium' : 'Free plan',
                color: primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark
        ? Color.lerp(const Color(0xFF0F1520), color, 0.08)!
        : Color.lerp(Colors.white, color, 0.06)!;
    final iconBg = color.withAlpha(isDark ? 45 : 30);
    final borderColor = color.withAlpha(isDark ? 60 : 45);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark
        ? Colors.white.withAlpha(140)
        : const Color(0xFF111827).withAlpha(140);

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.borderMd,
      child: InkWell(
        borderRadius: AppRadii.borderMd,
        splashColor: color.withAlpha(30),
        highlightColor: color.withAlpha(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadii.borderMd,
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(isDark ? 25 : 18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(color: titleColor, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 45 : 30),
        borderRadius: AppRadii.borderSm,
        border: Border.all(color: color.withAlpha(isDark ? 80 : 60)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ReliabilityCard extends StatelessWidget {
  const _ReliabilityCard({
    required this.engineHealthy,
    required this.lastCheckedAt,
    required this.engineDiagnostics,
  });

  final bool engineHealthy;
  final DateTime? lastCheckedAt;
  final Map<String, dynamic> engineDiagnostics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heartbeatAgeMs = _readInt(engineDiagnostics['heartbeatAgeMs']);
    final lastLockEvent = (engineDiagnostics['lastLockEvent'] as String?)?.trim();
    final lastLockEventAgeMs = _readInt(engineDiagnostics['lastLockEventAgeMs']);

    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F1520) : Colors.white;
    final borderCol = isDark
        ? Colors.white.withAlpha(22)
        : const Color(0xFF111827).withAlpha(18);
    final labelCol = isDark
        ? Colors.white.withAlpha(120)
        : const Color(0xFF111827).withAlpha(110);
    final valueCol = isDark ? Colors.white.withAlpha(200) : const Color(0xFF111827);
    final dotColor = engineHealthy ? const Color(0xFF2FA37C) : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'System Status',
                style: theme.textTheme.titleSmall?.copyWith(color: valueCol),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _DiagRow(label: 'Engine', value: engineHealthy ? 'Healthy' : 'Unhealthy', labelColor: labelCol, valueColor: engineHealthy ? const Color(0xFF2FA37C) : theme.colorScheme.error),
          _DiagRow(label: 'Last heartbeat', value: _formatAge(heartbeatAgeMs), labelColor: labelCol, valueColor: valueCol),
          _DiagRow(
            label: 'Last lock',
            value: lastLockEvent?.isNotEmpty == true ? '${lastLockEvent!} · ${_formatAge(lastLockEventAgeMs)}' : 'n/a',
            labelColor: labelCol,
            valueColor: valueCol,
          ),
          _DiagRow(
            label: 'Checked',
            value: lastCheckedAt?.toLocal().toString().split('.').first ?? 'n/a',
            labelColor: labelCol,
            valueColor: valueCol.withAlpha(150),
          ),
        ],
      ),
    );
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  String _formatAge(int? ageMs) {
    if (ageMs == null || ageMs < 0) return 'n/a';
    final seconds = (ageMs / 1000).round();
    if (seconds < 60) return '${seconds}s ago';
    final minutes = (seconds / 60).floor();
    if (minutes < 60) return '${minutes}m ago';
    final hours = (minutes / 60).floor();
    return '${hours}h ago';
  }
}

class _DiagRow extends StatelessWidget {
  const _DiagRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: labelColor)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall?.copyWith(color: valueColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.delayMs,
    required this.child,
  });

  final int delayMs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) return child;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 420 + delayMs),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, c) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 14),
          child: Opacity(opacity: value, child: c),
        );
      },
      child: child,
    );
  }
}
