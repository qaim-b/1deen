import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme_mode.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/settings/application/settings_controller.dart';
import 'package:app/features/settings/domain/app_settings.dart';
import 'package:app/features/settings/presentation/widgets/settings_section.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
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
        padding: AppSpacing.pagePadding(context),
        children: [
          Text('Settings', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Configure your spiritual practice',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(145),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Selected Apps & Categories',
            trailing: TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit'),
            ),
            child: _MutedBox(
              text: 'App/category picker UI placeholder. Blocking list is managed in native layer.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Prayer Calculation',
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.public_rounded,
                  label: 'Calculation Method',
                  sublabel: settings.prayerCalcMethod.label,
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<PrayerCalcMethod>(
                      value: settings.prayerCalcMethod,
                      items: PrayerCalcMethod.values
                          .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) settingsController.updatePrayerMethod(value);
                      },
                    ),
                  ),
                ),
                const Divider(height: 20),
                _SettingRow(
                  icon: Icons.straighten_rounded,
                  label: 'Asr Calculation',
                  sublabel: settings.strictnessMode.label,
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<StrictnessMode>(
                      value: settings.strictnessMode,
                      items: StrictnessMode.values
                          .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) settingsController.updateStrictness(value);
                      },
                    ),
                  ),
                ),
                const Divider(height: 20),
                _SettingRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  sublabel: 'Auto-detected from device',
                  trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withAlpha(110)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Appearance',
            child: Column(
              children: [
                _SettingRow(
                  icon: settings.themeMode == AppThemeMode.discipline ? Icons.dark_mode : Icons.light_mode,
                  label: 'Dark Mode',
                  sublabel: settings.themeMode == AppThemeMode.discipline ? 'Enabled' : 'Disabled',
                  trailing: Switch(
                    value: settings.themeMode == AppThemeMode.discipline,
                    onChanged: (enabled) {
                      settingsController.updateThemeMode(
                        enabled ? AppThemeMode.discipline : AppThemeMode.calm,
                      );
                    },
                  ),
                ),
                const Divider(height: 20),
                _SettingRow(
                  icon: Icons.language_rounded,
                  label: 'Language',
                  sublabel: 'English',
                  trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withAlpha(110)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Support & Legal',
            child: Column(
              children: const [
                _LinkRow(title: 'Contact Support', subtitle: 'Get Help'),
                Divider(height: 20),
                _LinkRow(title: 'Privacy Policy', subtitle: 'Read Privacy Policy'),
                Divider(height: 20),
                _LinkRow(title: 'Terms of Use', subtitle: 'Read Terms of Use'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Subscription',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Annual plan: JPY 10,000/year', style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: subscriptionController.processing ? null : subscriptionController.purchaseAnnual,
                        child: Text(subscriptionController.processing ? 'Processing...' : 'Upgrade'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: subscriptionController.processing ? null : subscriptionController.restorePurchases,
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (authController.enabled)
            SettingsSection(
              title: 'Account',
              child: Row(
                children: [
                  Expanded(
                    child: Text(authController.user?.email ?? 'No active session'),
                  ),
                  OutlinedButton(
                    onPressed: authController.processing ? null : authController.signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          if (authController.enabled) const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Diagnostics',
            child: Row(
              children: [
                Expanded(
                  child: Text('Recent events: ${diagnosticsController.events.length}'),
                ),
                OutlinedButton(onPressed: diagnosticsController.clear, child: const Text('Clear')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(130),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleSmall),
              Text(
                sublabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _MutedBox extends StatelessWidget {
  const _MutedBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(145),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(145),
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.primary),
      ],
    );
  }
}

