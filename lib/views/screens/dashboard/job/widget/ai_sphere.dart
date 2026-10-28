import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiSphereSection extends StatefulWidget {
  const AiSphereSection({
    super.key,
  });

  @override
  State<AiSphereSection> createState() => _AiSphereSectionState();
}

class _AiSphereSectionState extends State<AiSphereSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: AiSpherePainter(
              rotation: _controller.value * 2 * pi,
            ),
            child: Center(
              child: Text(
                "AI",
                style: TextStyle(
                  fontSize: 58.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.8),
                      blurRadius: 20.r,
                    ),
                    Shadow(
                      color: Colors.blueAccent.withValues(alpha: 0.7),
                      blurRadius: 35.r,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AiSpherePainter extends CustomPainter {
  final double rotation;

  AiSpherePainter({
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = min(size.width, size.height) * 0.36;

    // Outer glow
    final outerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.cyanAccent.withValues(alpha: 0.25),
          Colors.blueAccent.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius * 1.5,
        ),
      );

    canvas.drawCircle(
      center,
      radius * 1.5,
      outerGlow,
    );

    // Sphere
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        colors: const [
          Color(0xFF174E91),
          Color(0xFF082D67),
          Color(0xFF031A3D),
          Color(0xFF020E28),
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );

    canvas.drawCircle(
      center,
      radius,
      spherePaint,
    );

    // Vertical longitude lines
    final verticalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = Colors.cyanAccent.withValues(alpha: 0.55);

    for (int i = -5; i <= 5; i++) {
      final width = radius * (0.2 + i.abs() * 0.15);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: width,
          height: radius * 2,
        ),
        verticalPaint,
      );
    }

    // Horizontal latitude lines
    final horizontalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = Colors.blueAccent.withValues(alpha: 0.6);

    for (int i = -4; i <= 4; i++) {
      final y = center.dy + i * radius * 0.2;

      final horizontalRadius = sqrt(
        max(
          1,
          radius * radius -
              pow(y - center.dy, 2),
        ),
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, y),
          width: horizontalRadius * 2,
          height: radius * 0.28,
        ),
        horizontalPaint,
      );
    }

    // Outer glowing border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        transform: GradientRotation(rotation),
        colors: [
          Colors.cyanAccent,
          Colors.blueAccent,
          Colors.transparent,
          Colors.cyanAccent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );

    canvas.drawCircle(
      center,
      radius,
      borderPaint,
    );

    // Particles
    final random = Random(15);

    for (int i = 0; i < 35; i++) {
      final angle = random.nextDouble() * pi * 2;
      final distance = random.nextDouble() * radius;

      final x =
          center.dx + cos(angle + rotation * 0.2) * distance;

      final y =
          center.dy + sin(angle + rotation * 0.2) * distance;

      final particle = Paint()
        ..color = i % 2 == 0
            ? Colors.cyanAccent.withValues(alpha: 0.8)
            : Colors.blueAccent.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          2,
        );

      canvas.drawCircle(
        Offset(x, y),
        i % 5 == 0 ? 1.3 : 0.7,
        particle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AiSpherePainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}