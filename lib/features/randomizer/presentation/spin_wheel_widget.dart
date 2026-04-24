import 'package:flutter/material.dart';
import 'dart:math';
import '../../../models/preset.dart';

class SpinWheelWidget extends StatelessWidget {
  final List<Meal> meals;
  final double rotation;
  final double wheelSize;

  const SpinWheelWidget({
    super.key,
    required this.meals,
    required this.rotation,
    this.wheelSize = 350,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Rotating Wheel
        AnimatedRotation(
          turns: rotation,
          duration: const Duration(seconds: 2),
          curve: Curves.decelerate,
          child: SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: CustomPaint(painter: SpinWheelPainter(meals)),
          ),
        ),

        // Winner Indicator Triangle at top pointing to center
        Positioned(
          top: -10,
          child: SizedBox(
            width: 40,
            height: 30,
            child: CustomPaint(painter: WinnerIndicatorPainter()),
          ),
        ),
      ],
    );
  }
}

class SpinWheelPainter extends CustomPainter {
  final List<Meal> meals;

  SpinWheelPainter(this.meals);

  static const double _margin = 16.0;
  static const double _defaultFontSize = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final mealCount = meals.length;
    final sliceAngle = (2 * pi) / mealCount;

    // Calculate available radial space for text (with margins from center and edge)
    final maxTextWidth = radius - 2 * _margin;

    // Measure the longest meal name at default font size
    double longestWidth = 0;
    for (final meal in meals) {
      final tp = TextPainter(
        text: TextSpan(
          text: meal.name,
          style: const TextStyle(
            fontSize: _defaultFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      if (tp.width > longestWidth) {
        longestWidth = tp.width;
      }
    }

    // Scale font size down if the longest text exceeds available space
    final fontSize = (longestWidth > maxTextWidth && maxTextWidth > 0)
        ? _defaultFontSize * (maxTextWidth / longestWidth)
        : _defaultFontSize;

    // Text center positioned in the middle of the available radial space
    final textRadius = _margin + maxTextWidth / 2;

    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black;

    // List of vibrant colors for each slice
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    // Draw each slice
    for (int i = 0; i < mealCount; i++) {
      paint.color = colors[i % colors.length];

      final startAngle = i * sliceAngle - pi / 2;
      final sweepAngle = sliceAngle;

      // Draw the slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw slice border
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        strokePaint,
      );
    }

    // Draw outer circle border
    canvas.drawCircle(center, radius, strokePaint);
  }

  @override
  bool shouldRepaint(SpinWheelPainter oldDelegate) {
    return oldDelegate.meals != meals;
  }
}

class WinnerIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Triangle pointing down (toward the center of the wheel)
    final path = Path()
      ..moveTo(
        size.width / 2,
        size.height,
      ) // tip of arrow pointing down (toward center)
      ..lineTo(0, 0) // top left corner
      ..lineTo(size.width, 0) // top right corner
      ..close();

    canvas.drawPath(path, paint);

    // Draw stroke for visibility
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(WinnerIndicatorPainter oldDelegate) => false;
}
