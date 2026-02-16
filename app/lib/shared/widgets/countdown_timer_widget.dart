import 'dart:async';

import 'package:app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  const CountdownTimerWidget({
    required this.targetTime,
    this.style,
    this.prefix = '',
    super.key,
  });

  final DateTime targetTime;
  final TextStyle? style;
  final String prefix;

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  @override
  void didUpdateWidget(CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetTime != oldWidget.targetTime) {
      _updateRemaining();
    }
  }

  void _updateRemaining() {
    final diff = widget.targetTime.difference(DateTime.now());
    if (!mounted) return;
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (d.inHours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultStyle = AppTypography.mono(isDark: isDark).copyWith(
      color: Colors.white,
    );
    final formatted = _formatDuration(_remaining);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        '${widget.prefix}$formatted',
        key: ValueKey(formatted),
        style: widget.style ?? defaultStyle,
      ),
    );
  }
}
