import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/skleton/others/discover_categories_skelton.dart';
import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/categories_controller.dart';
import '../../../route/route_constants.dart';
import '../../home/views/components/sub_category.dart';
import '../models/category_data.dart';
import 'components/category_content_view.dart';
import 'components/category_sidebar_item.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final CategoriesController controller;
  final CartController _cart = CartController.instance;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarBg = isDark ? const Color(0xFF14141C) : const Color(0xFFF7F7F9);
    final contentBg = isDark ? const Color(0xFF1A1A24) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFE8E8EE);

    return Scaffold(
      backgroundColor: contentBg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161620) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.8,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        titleSpacing: Navigator.canPop(context) ? 0 : defaultPadding,
        title: Text(
          "ALL CATEGORIES",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1B1B22),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        actions: [
          // Search Icon
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/Search.svg",
              height: 22,
              width: 22,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : const Color(0xFF22222A),
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, searchScreenRoute);
            },
          ),

          // Wishlist Icon (Heart)
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/Wishlist.svg",
              height: 22,
              width: 22,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : const Color(0xFF22222A),
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, bookmarkScreenRoute);
            },
          ),

          // Cart Icon with live Badge
          AnimatedBuilder(
            animation: _cart,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/Bag.svg",
                      height: 22,
                      width: 22,
                      colorFilter: ColorFilter.mode(
                        isDark ? Colors.white : const Color(0xFF22222A),
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, cartScreenRoute);
                    },
                  ),
                  if (_cart.totalItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          "${_cart.totalItemCount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Container(
            color: isDark ? const Color(0xFF161620) : Colors.white,
            padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
            child: Obx(() {
              final activeType = controller.selectedCategoryType.value;
              return Row(
                children: [
                  _typeTab("all", "All", activeType, isDark),
                  const SizedBox(width: 8),
                  _typeTab("ecommerce", "E-Commerce", activeType, isDark,
                      icon: Icons.shopping_bag_outlined),
                  const SizedBox(width: 8),
                  _typeTab("food", "Food & Dining", activeType, isDark,
                      icon: Icons.restaurant_rounded),
                ],
              );
            }),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const DiscoverCategoriesSkelton();
          }

          final categories = controller.displayCategories;
          final useApi = categories.isNotEmpty;

          return Row(
            children: [
              // Left Sidebar (Categories)
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: sidebarBg,
                  border: Border(
                    right: BorderSide(
                      color: dividerColor,
                      width: 0.9,
                    ),
                  ),
                ),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: useApi ? categories.length : demoDiscoverCategories.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == controller.selectedIndex.value;

                    if (useApi) {
                      return CategorySidebarItem(
                        categoryModel: categories[index],
                        isSelected: isSelected,
                        onTap: () {
                          controller.selectCategory(index);
                        },
                      );
                    } else {
                      return CategorySidebarItem(
                        category: demoDiscoverCategories[index],
                        isSelected: isSelected,
                        onTap: () {
                          controller.selectCategory(index);
                        },
                      );
                    }
                  },
                ),
              ),

              // Right Pane (Subcategories & Live Products)
              Expanded(
                child: Container(
                  color: contentBg,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
                    child: useApi
                        ? const Sub_category()
                        : CategoryContentView(
                            category: demoDiscoverCategories[
                                controller.selectedIndex.value.clamp(0, demoDiscoverCategories.length - 1)],
                          ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _typeTab(
    String type,
    String label,
    String activeType,
    bool isDark, {
    IconData? icon,
  }) {
    final isSelected = activeType == type;

    return InkWell(
      onTap: () => controller.setCategoryType(type),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF222030) : const Color(0xFFF1F1F6)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white10 : const Color(0xFFE2E2E8)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF4A4A58)),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF4A4A58)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
