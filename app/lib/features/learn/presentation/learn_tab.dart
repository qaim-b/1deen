import 'package:app/features/ai/application/ai_service.dart';
import 'package:app/features/ai/presentation/ai_tab.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class LearnTab extends StatefulWidget {
  const LearnTab({
    required this.aiService,
    required this.subscriptionController,
    super.key,
  });

  final AiService aiService;
  final SubscriptionController subscriptionController;

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  bool _openAi = false;

  @override
  Widget build(BuildContext context) {
    if (_openAi) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _openAi = false),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Text('Learn with DeenLearner', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          Expanded(
            child: AiTab(
              aiService: widget.aiService,
              subscriptionController: widget.subscriptionController,
              embedded: true,
            ),
          ),
        ],
      );
    }

    final theme = Theme.of(context);

    return GradientScaffold(
      child: ListView(
        padding: AppSpacing.pagePadding(context),
        children: [
          Text('Learn', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Build consistent knowledge with short, practical daily study.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Focus', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Read Surah Al-Mulk and reflect on accountability.', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => setState(() => _openAi = true),
                    icon: const Icon(Icons.smart_toy_rounded),
                    label: const Text('Ask DeenLearner'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Micro Lessons', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  const _LessonRow(title: 'Wudu essentials', duration: '4 min'),
                  const Divider(height: 20),
                  const _LessonRow(title: 'Salah concentration', duration: '5 min'),
                  const Divider(height: 20),
                  const _LessonRow(title: 'Friday preparation', duration: '3 min'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_stories_rounded),
              title: const Text('Reading plans'),
              subtitle: const Text('Structured weekly paths are coming soon.'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.title, required this.duration});

  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Icon(Icons.play_circle_outline_rounded),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
        Text(duration, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
