import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    required this.onPressed,
    required this.child,
    this.loading = false,
    this.style,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool loading;
  final ButtonStyle? style;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTapDown: reduceMotion ? null : (_) => _controller.forward(),
      onTapUp: reduceMotion ? null : (_) => _controller.reverse(),
      onTapCancel: reduceMotion ? null : () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: FilledButton(
          onPressed: widget.loading ? null : widget.onPressed,
          style: widget.style,
          child: widget.loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}

class AnimatedOutlinedButton extends StatefulWidget {
  const AnimatedOutlinedButton({
    required this.onPressed,
    required this.child,
    this.loading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool loading;

  @override
  State<AnimatedOutlinedButton> createState() => _AnimatedOutlinedButtonState();
}

class _AnimatedOutlinedButtonState extends State<AnimatedOutlinedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: OutlinedButton(
          onPressed: widget.loading ? null : widget.onPressed,
          child: widget.loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}
