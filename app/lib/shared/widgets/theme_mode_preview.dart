import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme_mode.dart';
import 'package:flutter/material.dart';

class ThemeModePreview extends StatelessWidget {
  const ThemeModePreview({required this.mode, super.key});

  final AppThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final isCalm = mode == AppThemeMode.calm;

    final bgColor = isCalm ? AppColors.calmIvory : AppColors.disciplineCharcoal;
    final primary = isCalm ? AppColors.calmTeal : AppColors.disciplineEmber;
    final secondary = isCalm ? AppColors.calmGold : AppColors.disciplineMint;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: primary.withAlpha(80),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
