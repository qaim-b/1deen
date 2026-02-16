import 'package:flutter/material.dart';

class OrnamentalDivider extends StatelessWidget {
  const OrnamentalDivider({this.color, this.height = 24, super.key});

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        color ?? Theme.of(context).colorScheme.primary.withAlpha(40);

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _OrnamentalPainter(color: dividerColor),
      ),
    );
  }
}

class _OrnamentalPainter extends CustomPainter {
  _OrnamentalPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final diamondSize = 5.0;

    // Left line
    canvas.drawLine(
      Offset(size.width * 0.15, centerY),
      Offset(centerX - 16, centerY),
      paint,
    );

    // Right line
    canvas.drawLine(
      Offset(centerX + 16, centerY),
      Offset(size.width * 0.85, centerY),
      paint,
    );

    // Center diamond
    final diamondPath = Path()
      ..moveTo(centerX, centerY - diamondSize)
      ..lineTo(centerX + diamondSize, centerY)
      ..lineTo(centerX, centerY + diamondSize)
      ..lineTo(centerX - diamondSize, centerY)
      ..close();
    canvas.drawPath(diamondPath, fillPaint);

    // Small dots on either side
    canvas.drawCircle(Offset(centerX - 12, centerY), 1.5, fillPaint);
    canvas.drawCircle(Offset(centerX + 12, centerY), 1.5, fillPaint);
  }

  @override
  bool shouldRepaint(_OrnamentalPainter oldDelegate) =>
      oldDelegate.color != color;
}
