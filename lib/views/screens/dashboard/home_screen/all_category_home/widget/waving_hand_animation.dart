import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavingHand extends StatefulWidget {
  const WavingHand({
    super.key,
    this.size = 22,
  });

  final double size;

  @override
  State<WavingHand> createState() => _WavingHandState();
}

class _WavingHandState extends State<WavingHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _isWaving = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startWave();
  }

  void _startWave() {
    if (!mounted) return;

    setState(() => _isWaving = true);

    _controller.repeat(reverse: true);

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      _stopWave();
    });
  }

  void _stopWave() {
    if (!mounted) return;

    _controller.stop();

    setState(() => _isWaving = false);

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      _startWave();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isWaving) {
      return Text(
        "👋",
        style: TextStyle(fontSize: widget.size),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: math.sin(_controller.value * math.pi) * 0.45,
          alignment: const Alignment(-0.15, 0.9),
          child: child,
        );
      },
      child: Text(
        "👋",
        style: TextStyle(fontSize: widget.size),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}