import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/ai/application/ai_service.dart';
import 'package:app/features/ai/domain/ai_usage_snapshot.dart';
import 'package:app/features/ai/presentation/widgets/chat_bubble.dart';
import 'package:app/features/ai/presentation/widgets/usage_dashboard.dart';
import 'package:app/features/subscription/application/subscription_controller.dart';
import 'package:app/shared/widgets/animated_button.dart';
import 'package:app/shared/widgets/animated_panel.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:app/shared/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';

class AiTab extends StatefulWidget {
  const AiTab({
    required this.aiService,
    required this.subscriptionController,
    super.key,
  });

  final AiService aiService;
  final SubscriptionController subscriptionController;

  @override
  State<AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<AiTab> {
  final _promptController = TextEditingController();
  bool _loading = false;
  String? _answer;
  late AiUsageSnapshot _usage;

  @override
  void initState() {
    super.initState();
    _usage = widget.aiService.snapshot();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _answer = null;
    });

    try {
      await widget.subscriptionController.refreshFromBackend();
      final answer = await widget.aiService.ask(
        prompt: _promptController.text,
        tier: widget.subscriptionController.tier,
      );
      if (!mounted) return;
      setState(() {
        _answer = answer;
        _usage = widget.aiService.snapshot();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _answer = 'Error: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: ListView(
              padding: AppSpacing.pagePadding,
              children: [
                AnimatedPanel(
                  title: 'DeenLearner',
                  icon: Icons.smart_toy_outlined,
                  child: UsageDashboard(
                    usage: _usage,
                    tier: widget.subscriptionController.tier,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // AI response area
                if (_loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const TypingIndicator(),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Thinking...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_answer != null) ...[
                  ChatBubble(text: _answer!),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ),
          ),

          // Input area at bottom
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withAlpha(240),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.onSurface.withAlpha(15),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    maxLines: 3,
                    minLines: 1,
                    maxLength: 700,
                    decoration: InputDecoration(
                      hintText: 'Ask a short practical question...',
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '${_promptController.text.length}/700',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(80),
                          ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minHeight: 20,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedButton(
                  onPressed: _promptController.text.trim().isEmpty ? null : _ask,
                  loading: _loading,
                  child: const Icon(Icons.send_rounded, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
