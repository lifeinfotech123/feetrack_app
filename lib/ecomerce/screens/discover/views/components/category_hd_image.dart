import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../services/theme.dart';


class CategoryHdImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final IconData? fallbackIcon;
  final bool isCircle;

  const CategoryHdImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.shopping_bag_outlined,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderBg = isDark ? const Color(0xFF262630) : const Color(0xFFF3F3F5);

    Widget buildPlaceholder() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: placeholderBg,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    Widget buildFallback() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFF0EDFF),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Icon(
            fallbackIcon,
            size: (width != null ? width! * 0.45 : 24.0).clamp(16.0, 36.0).toDouble(),
            color: primaryColor,
          ),
        ),
      );
    }

    if (imageUrl.isEmpty) {
      return buildFallback();
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => buildPlaceholder(),
      errorWidget: (context, url, error) => buildFallback(),
    );

    if (isCircle) {
      return ClipOval(child: imageWidget);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageWidget,
    );
  }
}
