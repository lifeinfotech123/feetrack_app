import 'dart:math';
import 'package:flutter/material.dart';

class AiFlowBackground extends StatefulWidget {
  const AiFlowBackground({
    super.key,
  });

  @override
  State<AiFlowBackground> createState() => _AiFlowBackgroundState();
}

class _AiFlowBackgroundState extends State<AiFlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AiFlowPainter(
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class AiFlowPainter extends CustomPainter {
  final double animationValue;

  AiFlowPainter({
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.42;

    _drawMainFlow(
      canvas,
      size,
      centerY,
      0,
    );

    _drawMainFlow(
      canvas,
      size,
      centerY + 26,
      0.5,
    );

    _drawMainFlow(
      canvas,
      size,
      centerY - 28,
      1.0,
    );

    _drawSmallParticles(
      canvas,
      size,
    );
  }

  void _drawMainFlow(
    Canvas canvas,
    Size size,
    double centerY,
    double offset,
  ) {
    final path = Path();

    final animationOffset =
        sin((animationValue * 2 * pi) + offset) * 8;

    // LEFT START
    path.moveTo(
      -20,
      centerY + animationOffset,
    );

    // First wave
    path.cubicTo(
      size.width * 0.10,
      centerY - 35,
      size.width * 0.18,
      centerY - 35,
      size.width * 0.28,
      centerY,
    );

    // Second wave toward sphere
    path.cubicTo(
      size.width * 0.34,
      centerY + 20,
      size.width * 0.39,
      centerY + 30,
      size.width * 0.45,
      centerY,
    );

    // Around AI sphere
    path.cubicTo(
      size.width * 0.47,
      centerY - 40,
      size.width * 0.53,
      centerY - 40,
      size.width * 0.55,
      centerY,
    );

    // Exit sphere
    path.cubicTo(
      size.width * 0.61,
      centerY + 30,
      size.width * 0.66,
      centerY + 20,
      size.width * 0.72,
      centerY,
    );

    // RIGHT wave
    path.cubicTo(
      size.width * 0.82,
      centerY - 35,
      size.width * 0.90,
      centerY - 35,
      size.width + 20,
      centerY + animationOffset,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF13EFFF).withValues(alpha: 0.18),
          const Color(0xFF12EFFF).withValues(alpha: 0.8),
          const Color(0xFF1F79FF).withValues(alpha: 0.7),
          const Color(0xFF12EFFF).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawPath(path, paint);

    // Glow copy
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        7,
      )
      ..color = const Color(0xFF00E5FF).withValues(
        alpha: 0.08,
      );

    canvas.drawPath(path, glowPaint);
  }

  void _drawSmallParticles(
    Canvas canvas,
    Size size,
  ) {
    final random = Random(12);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final paint = Paint()
        ..color = Colors.cyanAccent.withValues(
          alpha: random.nextDouble() * 0.4,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          2,
        );

      canvas.drawCircle(
        Offset(x, y),
        random.nextDouble() * 1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AiFlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}