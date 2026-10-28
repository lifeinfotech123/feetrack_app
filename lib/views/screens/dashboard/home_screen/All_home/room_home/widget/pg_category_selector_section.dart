import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_category_model.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/widget/bootstrap_Icon/bootstrap_icon.dart';

class PgCategorySelectorSection extends StatelessWidget {
  const PgCategorySelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoomController>(
      builder: (roomController) {
        if (roomController.isCategoriesLoading &&
            roomController.pgCategoryList.isEmpty) {
          return SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => Container(
                width: 110,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          );
        }

        if (roomController.pgCategoryList.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = roomController.pgCategoryList;
        final selectedCat = roomController.selectedCategory;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                itemCount: categories.length + 1, // +1 for "All"
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final bool isAllSelected = selectedCat == null;
                    return _buildChip(
                      context: context,
                      title: "All",
                      icon: Icons.grid_view_rounded,
                      isSelected: isAllSelected,
                      count: null,
                      onTap: () => roomController.selectCategory(null),
                    );
                  }

                  final cat = categories[index - 1];
                  final bool isSelected =
                      selectedCat != null && selectedCat.slug == cat.slug;
                  final iconData = getBootstrapIcon(cat.icon);

                  return _buildChip(
                    context: context,
                    title: cat.name ?? "",
                    icon: iconData,
                    isSelected: isSelected,
                    count: cat.totalListings,
                    bgColorHex: cat.bgColor,
                    fgColorHex: cat.fgColor,
                    onTap: () => roomController.selectCategory(cat),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
    String? bgColorHex,
    String? fgColorHex,
  }) {
    Color? customFg;
    if (fgColorHex != null && fgColorHex.startsWith('#')) {
      try {
        customFg = Color(int.parse(fgColorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }

    final activeColor = primaryColor;
    final fg = isSelected ? Colors.white : (customFg ?? blackText1);
    final bg = isSelected
        ? activeColor
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? activeColor
                : Colors.grey.withValues(alpha: 0.18),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: fg,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: fg,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (customFg?.withValues(alpha: 0.12) ??
                          Colors.grey.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : (customFg ?? primaryColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
