import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/product/product_card.dart';
import '../../../constants.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../models/wishlist_model.dart';
import '../../../route/route_constants.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late final WishlistController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WishlistController.instance;
    _controller.fetchWishlist();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "My Wishlist",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final count = _controller.wishlistItems.length;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3366).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF3366),
                  ),
                ),
              );
            }),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardBg,
        actions: [
          IconButton(
            onPressed: () => _controller.fetchWishlist(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Wishlist",
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.wishlistItems.isEmpty) {
          return _buildLoadingSkeleton(isDark);
        }

        final items = _controller.wishlistItems;

        if (items.isEmpty) {
          return _buildEmptyState(context, isDark: isDark);
        }

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () => _controller.fetchWishlist(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.63,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final WishlistItemModel item = items[index];
                      final productModel = item.toProductModel();

                      return ProductCard(
                        id: item.productId,
                        shopId: item.shopId,
                        storeDomain: item.domain,
                        discountAmount: item.discount > 0 ? item.discount : null,
                        image: item.thumbnail != null && item.thumbnail!.isNotEmpty
                            ? item.thumbnail!
                            : productDemoImg1,
                        brandName: item.brandName ?? 'Store',
                        title: item.name,
                        price: item.unitPrice,
                        priceAfetDiscount: item.finalPrice < item.unitPrice
                            ? item.finalPrice
                            : null,
                        dicountpercent: productModel.dicountpercent,
                        press: () {
                          Navigator.pushNamed(
                            context,
                            productDetailsScreenRoute,
                            arguments: productModel,
                          );
                        },
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Skeleton loader for wishlist items
  Widget _buildLoadingSkeleton(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.63,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E28) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 60,
              height: 10,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 70,
              height: 14,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state UI
  Widget _buildEmptyState(BuildContext context, {required bool isDark}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3366).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 56,
                color: Color(0xFFFF3366),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Wishlist is Empty",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Explore products and tap the heart icon on any item to save it here for later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text("Explore Products"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
