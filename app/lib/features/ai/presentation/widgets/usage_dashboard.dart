import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/ai/domain/ai_usage_snapshot.dart';
import 'package:app/features/subscription/domain/subscription_tier.dart';
import 'package:app/shared/widgets/quota_progress_bar.dart';
import 'package:flutter/material.dart';

class UsageDashboard extends StatelessWidget {
  const UsageDashboard({
    required this.usage,
    required this.tier,
    super.key,
  });

  final AiUsageSnapshot usage;
  final SubscriptionTier tier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: tier == SubscriptionTier.premium
                    ? theme.colorScheme.primary.withAlpha(20)
                    : theme.colorScheme.onSurface.withAlpha(15),
                borderRadius: AppRadii.borderSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tier == SubscriptionTier.premium
                        ? Icons.workspace_premium_rounded
                        : Icons.person_outline_rounded,
                    size: 16,
                    color: tier == SubscriptionTier.premium
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(160),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    tier.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: tier == SubscriptionTier.premium
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withAlpha(160),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        QuotaProgressBar(
          label: 'Free daily queries',
          used: usage.freeUsedToday,
          cap: usage.freeDailyCap,
        ),
        const SizedBox(height: AppSpacing.md),
        QuotaProgressBar(
          label: 'Premium monthly queries',
          used: usage.premiumUsedMonth,
          cap: usage.premiumMonthlyCap,
          activeColor: theme.colorScheme.secondary,
        ),
      ],
    );
  }
}
