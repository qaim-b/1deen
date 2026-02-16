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
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withAlpha(175),
                borderRadius: AppRadii.borderMd,
                border: Border.all(color: theme.colorScheme.onSurface.withAlpha(18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Best results: keep Guard strict during study/work blocks.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withAlpha(40),
            theme.colorScheme.surface.withAlpha(170),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: theme.colorScheme.primary.withAlpha(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Home', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Protect your salah and your attention.', style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatusChip(
                label: healthy ? 'Guard healthy' : 'Guard needs attention',
                color: healthy ? const Color(0xFF2FA37C) : theme.colorScheme.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusChip(
                label: tier == SubscriptionTier.premium ? 'Premium' : 'Free plan',
                color: theme.colorScheme.primary,
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

    return InkWell(
      borderRadius: AppRadii.borderMd,
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppRadii.borderMd,
          gradient: LinearGradient(
            colors: [
              color.withAlpha(35),
              theme.colorScheme.surface.withAlpha(175),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withAlpha(70)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 3),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadii.borderSm,
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(165),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: theme.colorScheme.onSurface.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reliability', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text('Engine: ${engineHealthy ? 'healthy' : 'unhealthy'}', style: theme.textTheme.bodySmall),
          Text('Last heartbeat: ${_formatAge(heartbeatAgeMs)}', style: theme.textTheme.bodySmall),
          Text(
            'Last lock event: ${lastLockEvent?.isNotEmpty == true ? lastLockEvent : 'n/a'} (${_formatAge(lastLockEventAgeMs)})',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Last checked: ${lastCheckedAt?.toLocal().toString().split('.').first ?? 'n/a'}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150)),
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
