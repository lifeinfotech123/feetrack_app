import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';
import 'profile_controller.dart';

class WishlistController extends GetxController {
  static WishlistController get instance {
    if (Get.isRegistered<WishlistController>()) {
      return Get.find<WishlistController>();
    }
    return Get.put(WishlistController(), permanent: true);
  }

  final WishlistService _service = WishlistService();

  final RxList<WishlistItemModel> wishlistItems = <WishlistItemModel>[].obs;
  final RxSet<int> wishlistedProductIds = <int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString currentDomain = 'e-team-12'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  /// Check if a product is in the user's wishlist in O(1) time
  bool isWishlisted(int? productId) {
    if (productId == null || productId == 0) return false;
    return wishlistedProductIds.contains(productId);
  }

  /// Fetch Wishlist items from API
  Future<void> fetchWishlist({String? domain}) async {
    final effectiveDomain =
        (domain != null && domain.isNotEmpty) ? domain : currentDomain.value;
    currentDomain.value = effectiveDomain;

    isLoading.value = true;
    try {
      final items = await _service.getWishlist(domain: effectiveDomain);
      wishlistItems.assignAll(items);
      wishlistedProductIds.assignAll(items.map((e) => e.productId));

      // Sync with profile count if registered
      _syncProfileCount();
    } catch (e) {
      debugPrint('WishlistController fetchWishlist error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle product in wishlist (Add / Remove)
  Future<bool> toggleWishlist({
    required int? productId,
    String? domain,
    BuildContext? context,
  }) async {
    if (productId == null || productId == 0) return false;

    final effectiveDomain =
        (domain != null && domain.isNotEmpty) ? domain : currentDomain.value;

    final bool wasWishlisted = wishlistedProductIds.contains(productId);

    // 1. Optimistic Instant UI Update
    if (wasWishlisted) {
      wishlistedProductIds.remove(productId);
      wishlistItems.removeWhere((item) => item.productId == productId);
    } else {
      wishlistedProductIds.add(productId);
    }
    _syncProfileCount();

    // 2. Call API
    try {
      final res = await _service.toggleWishlist(
        productId: productId,
        domain: effectiveDomain,
      );

      if (res['status'] == true) {
        final dynamic data = res['data'];
        final bool isNowWishlisted = (data is Map && data['is_wishlisted'] == true) ||
            (data is Map && data['action'] == 'added');

        if (isNowWishlisted) {
          wishlistedProductIds.add(productId);
          if (context != null && context.mounted) {
            _showToast(context, "Added to Wishlist ❤️", isAdd: true);
          }
        } else {
          wishlistedProductIds.remove(productId);
          wishlistItems.removeWhere((item) => item.productId == productId);
          if (context != null && context.mounted) {
            _showToast(context, "Removed from Wishlist", isAdd: false);
          }
        }

        _syncProfileCount();
        // Refresh full list in background so all thumbnails & pricing are accurate
        _service.getWishlist(domain: effectiveDomain).then((items) {
          if (items.isNotEmpty) {
            wishlistItems.assignAll(items);
            wishlistedProductIds.assignAll(items.map((e) => e.productId));
            _syncProfileCount();
          }
        });

        return isNowWishlisted;
      } else {
        // Rollback optimistic update
        _rollback(productId, wasWishlisted);
        if (context != null && context.mounted) {
          _showToast(context, res['message']?.toString() ?? "Could not update wishlist", isError: true);
        }
        return wasWishlisted;
      }
    } catch (e) {
      debugPrint('WishlistController toggleWishlist error: $e');
      _rollback(productId, wasWishlisted);
      return wasWishlisted;
    }
  }

  void _rollback(int productId, bool wasWishlisted) {
    if (wasWishlisted) {
      wishlistedProductIds.add(productId);
    } else {
      wishlistedProductIds.remove(productId);
    }
    _syncProfileCount();
  }

  void _syncProfileCount() {
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().wishlistCount.value =
          wishlistedProductIds.length;
    }
  }

  void _showToast(BuildContext context, String message, {bool isAdd = false, bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : (isAdd ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              color: isError
                  ? Colors.white
                  : (isAdd ? const Color(0xFFFF4081) : Colors.white70),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? Colors.redAccent
            : const Color(0xFF1E1E28),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
