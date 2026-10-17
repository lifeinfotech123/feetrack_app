import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../components/skleton/others/categories_skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/categories_controller.dart';
import '../../../../models/category_model.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.put(CategoriesController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const CategoriesSkelton();
      }

      final categoriesList = controller.categories.isNotEmpty
          ? controller.categories
          : demoCategories;

      if (categoriesList.isEmpty) {
        return const SizedBox();
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            categoriesList.length,
            (index) {
              final category = categoriesList[index];
              final isActive = index == controller.selectedIndex.value;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? defaultPadding : defaultPadding / 2,
                  right:
                      index == categoriesList.length - 1 ? defaultPadding : 0,
                ),
                child: CategoryBtn(
                  category: category.name,
                  svgSrc: category.svgSrc,
                  icon: category.icon,
                  isActive: isActive,
                  press: () {
                    controller.selectCategory(index);
                    if (category.route != null) {
                      Navigator.pushNamed(context, category.route!);
                    }
                  },
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    this.icon,
    required this.isActive,
    required this.press,
  });

  final String category;
  final String? svgSrc;
  final String? icon;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: press,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFF5A35E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive
              ? null
              : (isDark ? const Color(0xFF222030) : const Color(0xFFF3F3F7)),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : (isDark ? Colors.white12 : const Color(0xFFE5E5EB)),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF7B61FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && icon!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: icon!,
                  height: 18,
                  width: 18,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.category_outlined,
                    size: 18,
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF42424E)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ] else if (svgSrc != null) ...[
              SvgPicture.asset(
                svgSrc!,
                height: 18,
                width: 18,
                colorFilter: ColorFilter.mode(
                  isActive
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF42424E)),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF33333E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
