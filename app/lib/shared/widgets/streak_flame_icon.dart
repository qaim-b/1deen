import 'package:flutter/material.dart';

class StreakFlameIcon extends StatefulWidget {
  const StreakFlameIcon({
    required this.active,
    this.size = 28,
    this.color,
    super.key,
  });

  final bool active;
  final double size;
  final Color? color;

  @override
  State<StreakFlameIcon> createState() => _StreakFlameIconState();
}

class _StreakFlameIconState extends State<StreakFlameIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StreakFlameIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion || !widget.active) {
      return Icon(
        Icons.local_fire_department_rounded,
        size: widget.size,
        color: widget.active ? color : color.withAlpha(60),
      );
    }

    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
        child: Icon(
          Icons.local_fire_department_rounded,
          size: widget.size,
          color: color,
        ),
      ),
    );
  }
}
