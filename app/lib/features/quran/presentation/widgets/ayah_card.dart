import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_typography.dart';
import 'package:app/features/quran/domain/quran_ayah.dart';
import 'package:app/shared/widgets/glassmorphic_card.dart';
import 'package:app/shared/widgets/ornamental_divider.dart';
import 'package:flutter/material.dart';

class AyahCard extends StatelessWidget {
  const AyahCard({required this.ayah, super.key});

  final QuranAyah ayah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Surah reference
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: AppRadii.borderSm,
                ),
                child: Text(
                  'Surah ${ayah.surah} : Ayah ${ayah.ayah}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Arabic text
          Text(
            ayah.text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTypography.arabic().copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Ornamental divider
          OrnamentalDivider(
            color: theme.colorScheme.primary.withAlpha(30),
          ),
        ],
      ),
    );
  }
}
