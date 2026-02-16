import 'package:app/core/theme/app_spacing.dart';
import 'package:app/shared/widgets/animated_check.dart';
import 'package:flutter/material.dart';

class HabitToggleRow extends StatelessWidget {
  const HabitToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          AnimatedCheck(
            checked: value,
            size: 28,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(
            icon,
            size: 20,
            color: value
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withAlpha(100),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                color: value
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
