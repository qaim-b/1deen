import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme_mode.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/settings/domain/app_settings.dart';
import 'package:app/features/settings/presentation/widgets/settings_section.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:app/features/subscription/domain/subscription_tier.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:app/shared/widgets/theme_mode_preview.dart';
import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({
    required this.settingsController,
    required this.subscriptionController,
    required this.authController,
    required this.diagnosticsController,
    super.key,
  });

  final SettingsController settingsController;
  final SubscriptionController subscriptionController;
  final AuthController authController;
  final DiagnosticsController diagnosticsController;

  @override
  Widget build(BuildContext context) {
    final settings = settingsController.settings;
    final theme = Theme.of(context);

    return GradientScaffold(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          SettingsSection(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: theme.textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<AppThemeMode>(
                  segments: AppThemeMode.values.map((mode) {
                    return ButtonSegment(
                      value: mode,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ThemeModePreview(mode: mode),
                          const SizedBox(width: AppSpacing.sm),
                          Text(mode.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  selected: {settings.themeMode},
                  onSelectionChanged: (values) => settingsController.updateThemeMode(values.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Lock Rules',
            icon: Icons.lock_clock_outlined,
            child: Column(
              children: [
                DropdownButtonFormField<PrayerCalcMethod>(
                  initialValue: settings.prayerCalcMethod,
                  decoration: const InputDecoration(labelText: 'Prayer method'),
                  items: PrayerCalcMethod.values
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settingsController.updatePrayerMethod(value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<StrictnessMode>(
                  initialValue: settings.strictnessMode,
                  decoration: const InputDecoration(labelText: 'Strictness'),
                  items: StrictnessMode.values
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settingsController.updateStrictness(value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _LabeledSlider(
                  label: 'Start before prayer',
                  value: settings.lockBeforeMinutes.toDouble(),
                  unit: 'min',
                  min: 0,
                  max: 30,
                  divisions: 30,
                  onChanged: (v) => settingsController.updateLockBefore(v.round()),
                ),
                const SizedBox(height: AppSpacing.sm),
                _LabeledSlider(
                  label: 'End after adhan',
                  value: settings.lockAfterMinutes.toDouble(),
                  unit: 'min',
                  min: 5,
                  max: 45,
                  divisions: 40,
                  onChanged: (v) => settingsController.updateLockAfter(v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Subscription',
            icon: Icons.workspace_premium_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Annual plan - JPY 10,000/year',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: subscriptionController.processing
                            ? null
                            : subscriptionController.purchaseAnnual,
                        icon: const Icon(Icons.workspace_premium_rounded),
                        label: Text(
                          subscriptionController.processing ? 'Processing...' : 'Upgrade',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: subscriptionController.processing
                          ? null
                          : subscriptionController.restorePurchases,
                      child: const Text('Restore'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Current tier: ${subscriptionController.tier.label}',
                  style: theme.textTheme.bodySmall,
                ),
                if (subscriptionController.lastError != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subscriptionController.lastError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: subscriptionController.earlySupporter,
                  title: const Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 18),
                      SizedBox(width: AppSpacing.sm),
                      Text('Early supporter'),
                    ],
                  ),
                  onChanged: subscriptionController.setEarlySupporter,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (authController.enabled) ...[
            SettingsSection(
              title: 'Account',
              icon: Icons.person_outline_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(authController.user?.email ?? 'No active session', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: authController.processing ? null : authController.signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          SettingsSection(
            title: 'Coming Soon',
            icon: Icons.upcoming_outlined,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                _FeatureChip(icon: Icons.qr_code_scanner_rounded, label: 'Halal Scanner'),
                _FeatureChip(icon: Icons.map_rounded, label: 'Masjid Map'),
                _FeatureChip(icon: Icons.history_rounded, label: 'AI History'),
                _FeatureChip(icon: Icons.headphones_rounded, label: 'Quran Audio'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Diagnostics',
            icon: Icons.health_and_safety_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent events: ${diagnosticsController.events.length}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (diagnosticsController.events.isNotEmpty)
                  Text(
                    '${diagnosticsController.events.first.level.toUpperCase()} - ${diagnosticsController.events.first.event}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: diagnosticsController.clear,
                  child: const Text('Clear logs'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final String unit;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                '${value.round()} $unit',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withAlpha(8),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: theme.colorScheme.onSurface.withAlpha(15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurface.withAlpha(100)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}
