import 'dart:math' as math;

import 'package:flutter/material.dart';

class SemiCircle extends StatelessWidget {
  final double diameter;
  final Color color;
  final bool upSide;

  const SemiCircle({super.key, this.diameter = 200, required this.color, required this.upSide});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SemiCirclePainter(color, upSide),
      size: Size(diameter, diameter),
    );
  }
}

class SemiCirclePainter extends CustomPainter {
  final Color color;
  final bool upSide;

  SemiCirclePainter(this.color, this.upSide);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.height / 2, size.width / 2),
        height: size.height,
        width: size.width,
      ),
      upSide ? math.pi : 0,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // I just want to test this quickly right now so whatever just repaint
    return true;
  }
}