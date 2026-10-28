import 'package:flutter/material.dart';
import '../../../../models/category_model.dart';
import '../../models/category_data.dart';
import 'category_hd_image.dart';

class CategorySidebarItem extends StatelessWidget {
  final MainCategory? category;
  final CategoryModel? categoryModel;
  final String? title;
  final String? image;
  final IconData? fallbackIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategorySidebarItem({
    super.key,
    this.category,
    this.categoryModel,
    this.title,
    this.image,
    this.fallbackIcon,
    required this.isSelected,
    required this.onTap,
  });

  String get displayTitle =>
      categoryModel?.name ??
      categoryModel?.title ??
      category?.title ??
      title ??
      '';

  String get displayImage =>
      categoryModel?.icon ??
      categoryModel?.image ??
      category?.image ??
      image ??
      '';

  IconData get displayFallbackIcon =>
      category?.fallbackIcon ?? fallbackIcon ?? Icons.category_outlined;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = Color(0xFF9C27B0); // Vibrant purple like the screenshot

    return Material(
      color: isSelected
          ? (isDark ? const Color(0xFF1F1F2A) : Colors.white)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Left active indicator strip
            if (isSelected)
              Positioned(
                left: 0,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(4),
                    ),
                  ),
                ),
              ),

            // Item content
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular image/icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (isDark ? const Color(0xFF2D2438) : const Color(0xFFF9EEFF))
                          : (isDark ? const Color(0xFF262630) : const Color(0xFFF0F0F3)),
                      border: Border.all(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.35)
                            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CategoryHdImage(
                        imageUrl: displayImage,
                        isCircle: true,
                        fallbackIcon: displayFallbackIcon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Category title
                  Text(
                    displayTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? const Color(0xFFCE93D8) : accentColor)
                          : (isDark ? const Color(0xFFC0C0C8) : const Color(0xFF383842)),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
