import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/wishlist_controller.dart';

class WishlistHeartButton extends StatefulWidget {
  final int? productId;
  final String? storeDomain;
  final double size;
  final double iconSize;
  final Color filledColor;
  final Color? outlinedColor;
  final Color? backgroundColor;

  const WishlistHeartButton({
    super.key,
    required this.productId,
    this.storeDomain,
    this.size = 28,
    this.iconSize = 15,
    this.filledColor = const Color(0xFFFF3366),
    this.outlinedColor,
    this.backgroundColor,
  });

  @override
  State<WishlistHeartButton> createState() => _WishlistHeartButtonState();
}

class _WishlistHeartButtonState extends State<WishlistHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.productId == null || widget.productId == 0) return;
    _animCtrl.forward(from: 0.0);
    WishlistController.instance.toggleWishlist(
      productId: widget.productId,
      domain: widget.storeDomain,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productId == null || widget.productId == 0) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = widget.backgroundColor ??
        (isDark
            ? Colors.black.withValues(alpha: 0.55)
            : Colors.white.withValues(alpha: 0.9));
    final defaultOutlined = widget.outlinedColor ??
        (isDark ? Colors.white70 : const Color(0xFF757575));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          color: defaultBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Obx(() {
              final isFav =
                  WishlistController.instance.isWishlisted(widget.productId);
              return Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: widget.iconSize,
                color: isFav ? widget.filledColor : defaultOutlined,
              );
            }),
          ),
        ),
      ),
    );
  }
}
