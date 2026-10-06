import 'package:flutter/material.dart';
import '../theme.dart';

class HairlineDivider extends StatelessWidget {
  final bool withChecker;

  const HairlineDivider({super.key, this.withChecker = false});

  @override
  Widget build(BuildContext context) {
    if (!withChecker) {
      return const Divider(
        height: 1,
        thickness: 1,
        color: AppTheme.hairline,
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 2),
      painter: _HairlineCheckerPainter(),
    );
  }
}

class _HairlineCheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.hairline
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal hairline
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Draw 2x2 checker at the start (left end)
    final fillPaint = Paint()
      ..color = AppTheme.hairline
      ..style = PaintingStyle.fill;
      
    // 2x2 squares, drawn as 4 small rects (2 filled, 2 empty)
    // top-left and bottom-right filled
    canvas.drawRect(const Rect.fromLTWH(0, 0, 2, 2), fillPaint);
    canvas.drawRect(const Rect.fromLTWH(2, 2, 2, 2), fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
