import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';
import 'home_screen_api_controller.dart';
import 'profile_controller.dart';
import 'store_controller.dart';

class WishlistController extends GetxController {
  static WishlistController get instance {
    if (Get.isRegistered<WishlistController>()) {
      return Get.find<WishlistController>();
    }
    return Get.put(WishlistController(), permanent: true);
  }

  final WishlistService _service = WishlistService();

  final RxList<WishlistItemModel> wishlistItems = <WishlistItemModel>[].obs;
  // Key format: "$domain-$productId"
  final RxSet<String> wishlistedKeys = <String>{}.obs;
  final RxSet<int> wishlistedProductIds = <int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString currentDomain = 'e-team-12'.obs;
  final RxSet<String> knownDomains =
      <String>{'e-team-12', '21-ecomm', '25-ecomm'}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  String _makeKey(int? productId, String? domain) {
    final d = (domain != null && domain.trim().isNotEmpty)
        ? domain.trim()
        : currentDomain.value;
    return '$d-$productId';
  }

  /// Check if a product is in the user's wishlist
  bool isWishlisted(int? productId, {String? domain}) {
    if (productId == null || productId == 0) return false;
    if (domain != null && domain.trim().isNotEmpty) {
      final key = _makeKey(productId, domain);
      if (wishlistedKeys.contains(key)) return true;
    }
    // Fallback: check by product id
    return wishlistedProductIds.contains(productId);
  }

  void _collectActiveDomains() {
    if (Get.isRegistered<HomeScreenApiController>()) {
      final homeCtrl = Get.find<HomeScreenApiController>();
      for (final p in homeCtrl.allProducts) {
        final d = p.store?.domain?.trim();
        if (d != null && d.isNotEmpty) {
          knownDomains.add(d);
        }
      }
    }
    if (Get.isRegistered<StoreController>()) {
      final storeCtrl = Get.find<StoreController>();
      for (final s in storeCtrl.stores) {
        final d = s.domain?.trim();
        if (d != null && d.isNotEmpty) {
          knownDomains.add(d);
        }
      }
    }
  }

  /// Fetch Wishlist items from all active store domains
  Future<void> fetchWishlist({String? domain}) async {
    isLoading.value = true;
    try {
      _collectActiveDomains();
      if (domain != null && domain.trim().isNotEmpty) {
        knownDomains.add(domain.trim());
      }

      final items = await _service.getWishlist(
        domain: domain,
        domains: knownDomains,
      );
      wishlistItems.assignAll(items);

      final newKeys = <String>{};
      final newIds = <int>{};
      for (final item in items) {
        newKeys.add(_makeKey(item.productId, item.domain));
        newIds.add(item.productId);
      }
      wishlistedKeys.assignAll(newKeys);
      wishlistedProductIds.assignAll(newIds);

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

    final effectiveDomain = (domain != null && domain.trim().isNotEmpty)
        ? domain.trim()
        : currentDomain.value;
    knownDomains.add(effectiveDomain);

    final key = _makeKey(productId, effectiveDomain);
    final bool wasWishlisted = wishlistedKeys.contains(key) ||
        wishlistItems.any((item) =>
            item.productId == productId && item.domain == effectiveDomain);

    // 1. Optimistic Instant UI Update
    if (wasWishlisted) {
      wishlistedKeys.remove(key);
      wishlistItems.removeWhere((item) =>
          item.productId == productId && item.domain == effectiveDomain);
      if (!wishlistItems.any((item) => item.productId == productId)) {
        wishlistedProductIds.remove(productId);
      }
    } else {
      wishlistedKeys.add(key);
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
        final bool isNowWishlisted =
            (data is Map && data['is_wishlisted'] == true) ||
            (data is Map && data['action'] == 'added');

        if (isNowWishlisted) {
          wishlistedKeys.add(key);
          wishlistedProductIds.add(productId);
          if (context != null && context.mounted) {
            _showToast(context, "Added to Wishlist ❤️", isAdd: true);
          }
        } else {
          wishlistedKeys.remove(key);
          wishlistItems.removeWhere((item) =>
              item.productId == productId && item.domain == effectiveDomain);
          if (!wishlistItems.any((item) => item.productId == productId)) {
            wishlistedProductIds.remove(productId);
          }
          if (context != null && context.mounted) {
            _showToast(context, "Removed from Wishlist", isAdd: false);
          }
        }

        _syncProfileCount();
        // Refresh all domains in background to get full item objects
        fetchWishlist();

        return isNowWishlisted;
      } else {
        // Rollback optimistic update
        _rollback(productId, effectiveDomain, wasWishlisted);
        if (context != null && context.mounted) {
          _showToast(
            context,
            res['message']?.toString() ?? "Could not update wishlist",
            isError: true,
          );
        }
        return wasWishlisted;
      }
    } catch (e) {
      debugPrint('WishlistController toggleWishlist error: $e');
      _rollback(productId, effectiveDomain, wasWishlisted);
      return wasWishlisted;
    }
  }

  void _rollback(int productId, String domain, bool wasWishlisted) {
    final key = _makeKey(productId, domain);
    if (wasWishlisted) {
      wishlistedKeys.add(key);
      wishlistedProductIds.add(productId);
    } else {
      wishlistedKeys.remove(key);
      if (!wishlistItems.any((item) => item.productId == productId)) {
        wishlistedProductIds.remove(productId);
      }
    }
    _syncProfileCount();
  }

  void _syncProfileCount() {
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().wishlistCount.value =
          wishlistItems.length;
    }
  }

  void _showToast(
    BuildContext context,
    String message, {
    bool isAdd = false,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : (isAdd
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded),
              color: isError
                  ? Colors.white
                  : (isAdd ? const Color(0xFFFF4081) : Colors.white70),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? Colors.redAccent : const Color(0xFF1E1E28),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
