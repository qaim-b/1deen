import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/quran/data/quran_repository.dart';
import 'package:app/features/quran/domain/quran_ayah.dart';
import 'package:app/features/quran/presentation/widgets/ayah_card.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:app/shared/widgets/shimmer_placeholder.dart';
import 'package:flutter/material.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({required this.quranRepository, super.key});

  final QuranRepository quranRepository;

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> with TickerProviderStateMixin {
  bool _loading = true;
  List<QuranAyah> _ayahs = const [];
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadQuran();
  }

  Future<void> _loadQuran() async {
    final ayahs = await widget.quranRepository.loadSampleAyahs();
    if (!mounted) return;
    setState(() {
      _ayahs = ayahs;
      _loading = false;
    });
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: _loading
          ? const ShimmerList(itemCount: 3, itemHeight: 180)
          : ListView.builder(
              padding: AppSpacing.pagePadding,
              itemCount: _ayahs.length,
              itemBuilder: (context, index) {
                final total = _ayahs.length;
                final start = (index / total) * 0.6;
                final end = start + 0.4;
                final reduceMotion =
                    MediaQuery.of(context).disableAnimations;

                final opacity = reduceMotion
                    ? const AlwaysStoppedAnimation(1.0)
                    : CurvedAnimation(
                        parent: _staggerController,
                        curve: Interval(
                          start.clamp(0.0, 1.0),
                          end.clamp(0.0, 1.0),
                          curve: Curves.easeOut,
                        ),
                      );

                final slide = reduceMotion
                    ? const AlwaysStoppedAnimation(Offset.zero)
                    : Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _staggerController,
                        curve: Interval(
                          start.clamp(0.0, 1.0),
                          end.clamp(0.0, 1.0),
                          curve: Curves.easeOut,
                        ),
                      ));

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: FadeTransition(
                    opacity: opacity,
                    child: SlideTransition(
                      position: slide,
                      child: AyahCard(ayah: _ayahs[index]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
