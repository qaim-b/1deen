import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxContentWidth = width >= 1400 ? 1160.0 : width >= 1100 ? 980.0 : 720.0;

        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
