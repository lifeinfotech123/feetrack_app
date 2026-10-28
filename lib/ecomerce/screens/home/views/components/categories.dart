import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../components/skleton/others/categories_skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/categories_controller.dart';
import '../../../../models/category_model.dart';
import '../../../product/views/category_products_screen.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  Timer? _resumeTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    // Continuous smooth auto-scrolling (approx ~25px per second)
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted || !_scrollController.hasClients || _isUserInteracting) return;

      final maxExtent = _scrollController.position.maxScrollExtent;
      final currentOffset = _scrollController.offset;

      if (currentOffset >= maxExtent - 10) {
        _scrollController.jumpTo(0.0);
      } else {
        _scrollController.jumpTo(currentOffset + 0.75);
      }
    });
  }

  void _onUserTouchStart() {
    _isUserInteracting = true;
    _resumeTimer?.cancel();
  }

  void _onUserTouchEnd() {
    _resumeTimer?.cancel();
    // Resume auto-scroll 2 seconds after user finishes interacting
    _resumeTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _isUserInteracting = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return const CategoriesSkelton();
      }

      // Filter out all food categories on eCommerce home screen
      final categoriesList = controller.homeCategories.isNotEmpty
          ? controller.homeCategories
          : demoCategories.where((c) => !c.isFood).toList();

      if (categoriesList.isEmpty) {
        return const SizedBox.shrink();
      }

      final isRepeating = categoriesList.length > 1;
      final itemCount = isRepeating ? categoriesList.length * 1000 : categoriesList.length;

      return Listener(
        onPointerDown: (_) => _onUserTouchStart(),
        onPointerUp: (_) => _onUserTouchEnd(),
        onPointerCancel: (_) => _onUserTouchEnd(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              _onUserTouchStart();
            } else if (notification is ScrollEndNotification) {
              _onUserTouchEnd();
            }
            return false;
          },
          child: SizedBox(
            height: 98,
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final category = categoriesList[index % categoriesList.length];
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: FlipkartCategoryCircleItem(
                    category: category,
                    isDark: isDark,
                    onTap: () {
                      controller.selectCategoryModel(category);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsScreen(
                            category: category,
                            categoryTitle: category.name,
                            categoryImage: category.icon,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

/// Flipkart-style circular category icon with label
class FlipkartCategoryCircleItem extends StatelessWidget {
  final CategoryModel category;
  final bool isDark;
  final VoidCallback onTap;

  const FlipkartCategoryCircleItem({
    super.key,
    required this.category,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconUrl = category.icon ?? category.image;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        width: 66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Icon Container with subtle gradient border
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2E2640), const Color(0xFF1E1C2B)]
                      : [const Color(0xFFF7F3FF), const Color(0xFFEDE5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark
                      ? primaryColor.withValues(alpha: 0.3)
                      : primaryColor.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: iconUrl != null && iconUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: iconUrl,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => Icon(
                            category.isFood
                                ? Icons.fastfood_rounded
                                : Icons.category_rounded,
                            size: 24,
                            color: primaryColor,
                          ),
                        )
                      : (category.svgSrc != null
                          ? SvgPicture.asset(
                              category.svgSrc!,
                              colorFilter: const ColorFilter.mode(
                                primaryColor,
                                BlendMode.srcIn,
                              ),
                            )
                          : const Icon(
                              Icons.category_rounded,
                              size: 24,
                              color: primaryColor,
                            )),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Category Label (Flipkart 2-line max)
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE0E0E8) : const Color(0xFF282834),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
