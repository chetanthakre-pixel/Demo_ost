import 'package:flutter/material.dart';
import '../theme.dart';

class RingsBackground extends StatelessWidget {
  final Widget child;

  const RingsBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingsPainter(),
      child: child,
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.hairline.withAlpha(38) // 0.15 * 255 = ~38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height * 0.3);
    final maxRadius = size.longestSide * 1.5;

    for (double r = 50; r < maxRadius; r += 80) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
