import 'dart:ui';

import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GlassmorphicCard extends StatelessWidget {
  const GlassmorphicCard({
    required this.child,
    this.borderRadius = AppRadii.lg,
    this.padding = AppSpacing.cardPaddingLegacy,
    super.key,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppExtendedTheme>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: ext.glassSigma, sigmaY: ext.glassSigma),
        child: Container(
          decoration: BoxDecoration(
            gradient: ext.glassGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: ext.glassBorderColor, width: 1),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}


