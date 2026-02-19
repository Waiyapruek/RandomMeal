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
    this.wheelSize = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
          top: 0,
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

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final mealCount = meals.length;
    final sliceAngle = (2 * pi) / mealCount;

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

      // Draw meal name text
      _drawMealName(
        canvas,
        center,
        radius,
        startAngle,
        sweepAngle,
        meals[i].name,
      );
    }

    // Draw outer circle border
    canvas.drawCircle(center, radius, strokePaint);
  }

  void _drawMealName(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    String mealName,
  ) {
    // Calculate the angle at middle of the slice
    final midAngle = startAngle + sweepAngle / 2;

    // Position text at 60% of radius from center
    final textRadius = radius * 0.6;
    final textOffset = Offset(
      center.dx + textRadius * cos(midAngle),
      center.dy + textRadius * sin(midAngle),
    );

    // Create TextPainter for the meal name
    final textPainter = TextPainter(
      text: TextSpan(
        text: mealName,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Rotate text so it points radially toward the center of wheel
    canvas.save();
    canvas.translate(textOffset.dx, textOffset.dy);
    // Rotate by midAngle + pi to make text point inward toward center
    canvas.rotate(midAngle + pi);
    // Draw text centered at this position
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
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
