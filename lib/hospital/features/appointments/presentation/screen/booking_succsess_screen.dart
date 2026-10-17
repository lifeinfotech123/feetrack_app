import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../dashboard/presentation/screen/dashboard_screen.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';

class BookingSuccsessScreen extends StatefulWidget {
  final String? bookingId;
  final String? title;
  final String? doctorName;
  final String? date;
  final String? time;
  final String? amount;

  const BookingSuccsessScreen({
    Key? key,
    this.bookingId,
    this.title,
    this.doctorName,
    this.date,
    this.time,
    this.amount,
  }) : super(key: key);

  @override
  State<BookingSuccsessScreen> createState() => _BookingSuccsessScreenState();
}

class _BookingSuccsessScreenState extends State<BookingSuccsessScreen>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late AnimationController _contentController;
  late AnimationController _confettiController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkRotationAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  final List<_ConfettiParticle> _particles = List.generate(
    35,
    (index) => _ConfettiParticle.generate(),
  );

  @override
  void initState() {
    super.initState();

    // Badge animation controller
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _rippleAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Content entry controller
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Confetti animation controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Sequence start
    _badgeController.forward().then((_) {
      _contentController.forward();
      _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingRef =
        widget.bookingId ?? 'HMS-${math.Random().nextInt(89999) + 10000}';
    final doctor = widget.doctorName ?? 'Dr. Jane Cooper';
    final service = widget.title ?? 'General Consultation & Checkup';
    final bookingDate = widget.date ?? '15 Sep 2026, 10:30 AM';
    final totalPaid = widget.amount != null
        ? (widget.amount!.startsWith('₹')
            ? widget.amount!
            : '₹${widget.amount}')
        : '₹500.00';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HospitalDashboardScreen(),
          ),
          (route) => route.isFirst,
        );
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              // Floating animated confetti background
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _confettiController.value,
                    ),
                  );
                },
              ),

              // Main Content Area
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Animated Hero Success Badge with ripples
                    Center(
                      child: AnimatedBuilder(
                        animation: _badgeController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulsing aura
                              Transform.scale(
                                scale: _rippleAnimation.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: wellnessGreen.withOpacity(
                                      (1.3 - _rippleAnimation.value)
                                          .clamp(0.0, 0.25),
                                    ),
                                  ),
                                ),
                              ),
                              // Middle soft glow ring
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: wellnessGreenBg,
                                  boxShadow: [
                                    BoxShadow(
                                      color: wellnessGreen.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              // Inner main circle with icon
                              Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _checkRotationAnimation.value,
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF43A047),
                                          Color(0xFF2E7D32)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x552E7D32),
                                          blurRadius: 15,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 54,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Animated Staggered Content
                    FadeTransition(
                      opacity: _contentOpacity,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            // Success Title & Subtitle
                            const Text(
                              'Booking Successful!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                                letterSpacing: -0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your appointment has been confirmed.\nA notification was sent to your registered details.',
                              style: TextStyle(
                                fontSize: 13,
                                color: textMuted,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 28),

                            // Booking Details Card
                            ModernCard(
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Card Top Bar: Reference ID & Copy button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: fillColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'BOOKING REFERENCE',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: primaryDark,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              bookingRef,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(text: bookingRef),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Booking reference copied to clipboard!',
                                                ),
                                                duration: Duration(seconds: 2),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.copy_rounded,
                                                  size: 16,
                                                  color: primaryColor,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Copy',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  const Divider(height: 1, color: borderGrey),
                                  const SizedBox(height: 16),

                                  // Details Rows
                                  _buildDetailRow(
                                    icon: Icons.medical_services_outlined,
                                    iconColor: primaryColor,
                                    label: 'Service / Purpose',
                                    value: service,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildDetailRow(
                                    icon: Icons.person_outline_rounded,
                                    iconColor: diagnosticViolet,
                                    label: 'Doctor Name',
                                    value: doctor,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildDetailRow(
                                    icon: Icons.calendar_today_outlined,
                                    iconColor: pharmacyTeal,
                                    label: 'Date & Time',
                                    value: bookingDate,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildDetailRow(
                                    icon: Icons.payment_outlined,
                                    iconColor: wellnessGreen,
                                    label: 'Amount Paid',
                                    value: totalPaid,
                                    valueColor: wellnessGreen,
                                    isBold: true,
                                  ),

                                  const SizedBox(height: 16),
                                  const Divider(height: 1, color: borderGrey),
                                  const SizedBox(height: 16),

                                  // Status Badge
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Payment Status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textMuted,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: wellnessGreenBg,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color:
                                                wellnessGreen.withOpacity(0.3),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 14,
                                              color: wellnessGreen,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Confirmed & Paid',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: wellnessGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Action Buttons
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const HospitalDashboardScreen(),
                                    ),
                                    (route) => route.isFirst,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  shadowColor: primaryColor.withOpacity(0.4),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.home_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Back to Dashboard',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Downloading digital receipt...',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: const BorderSide(color: primaryColor),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.download_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Download E-Receipt',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Helper model for confetti particles
class _ConfettiParticle {
  final double xRatio;
  final double startY;
  final double size;
  final Color color;
  final double speed;
  final double swaySpeed;

  _ConfettiParticle({
    required this.xRatio,
    required this.startY,
    required this.size,
    required this.color,
    required this.speed,
    required this.swaySpeed,
  });

  factory _ConfettiParticle.generate() {
    final rand = math.Random();
    final colors = [
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFF7E57C2),
      const Color(0xFFFF7043),
      const Color(0xFFFFA000),
      const Color(0xFF00897B),
    ];
    return _ConfettiParticle(
      xRatio: rand.nextDouble(),
      startY: -20 - rand.nextDouble() * 100,
      size: 6 + rand.nextDouble() * 8,
      color: colors[rand.nextInt(colors.length)],
      speed: 0.8 + rand.nextDouble() * 1.2,
      swaySpeed: 2 + rand.nextDouble() * 4,
    );
  }
}

/// Custom painter for rendering lightweight animated confetti
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    for (var p in particles) {
      final y = p.startY + (size.height + 150) * (progress * p.speed);
      if (y < 0 || y > size.height + 20) continue;

      final sway = math.sin(progress * math.pi * p.swaySpeed) * 20;
      final x = (p.xRatio * size.width) + sway;

      final opacity = (1.0 - (progress * 0.8)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * p.swaySpeed);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.7,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
