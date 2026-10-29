import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  final http.Client _client = http.Client();

  Future<String> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token') ??
          prefs.getString('user_app_token') ??
          '';
    } catch (_) {
      return '';
    }
  }

  /// 1. Get Wishlist Items (queries all active ecommerce store domains concurrently)
  /// GET api/v1/ecommerce/wishlist?domain={domain}
  Future<List<WishlistItemModel>> getWishlist({
    String? domain,
    Iterable<String>? domains,
  }) async {
    final Set<String> targetDomains = {};
    if (domain != null && domain.trim().isNotEmpty) {
      targetDomains.add(domain.trim());
    }
    if (domains != null) {
      targetDomains.addAll(domains.where((d) => d.trim().isNotEmpty));
    }
    // Always query core ecommerce store domains
    targetDomains.addAll(['e-team-12', '21-ecomm', '25-ecomm']);

    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final List<WishlistItemModel> allItems = [];
      final Set<int> seenWishlistIds = {};

      await Future.wait(
        targetDomains.map((d) async {
          try {
            final url = Uri.parse('${ecomBaseUrl}wishlist?domain=$d');
            final res = await _client.get(url, headers: headers);
            if (res.statusCode == 200) {
              final decoded = jsonDecode(res.body);
              if (decoded['status'] == true &&
                  decoded['data'] is Map<String, dynamic>) {
                final data = decoded['data'] as Map<String, dynamic>;
                final rawItems = data['items'];
                if (rawItems is List) {
                  for (final j in rawItems) {
                    if (j is Map<String, dynamic>) {
                      final item =
                          WishlistItemModel.fromJson(j, defaultDomain: d);
                      if (!seenWishlistIds.contains(item.wishlistId)) {
                        seenWishlistIds.add(item.wishlistId);
                        allItems.add(item);
                      }
                    }
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('WishlistService error fetching domain $d: $e');
          }
        }),
      );

      // Sort newest items first by wishlistId
      allItems.sort((a, b) => b.wishlistId.compareTo(a.wishlistId));
      return allItems;
    } catch (e) {
      debugPrint('WishlistService getWishlist error: $e');
    }
    return [];
  }

  /// 2. Add to Wishlist
  /// POST api/v1/ecommerce/wishlist/add
  Future<Map<String, dynamic>> addToWishlist({
    required int productId,
    String? domain,
  }) async {
    final effectiveDomain =
        (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';
    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('${ecomBaseUrl}wishlist/add');
      final body = jsonEncode({
        'domain': effectiveDomain,
        'product_id': productId.toString(),
      });

      final res = await _client.post(url, headers: headers, body: body);
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint('WishlistService addToWishlist error: $e');
    }
    return {'status': false, 'message': 'Network error'};
  }

  /// 3. Toggle Wishlist (Add if absent, Remove if present)
  /// POST api/v1/ecommerce/wishlist/toggle
  Future<Map<String, dynamic>> toggleWishlist({
    required int productId,
    String? domain,
  }) async {
    final effectiveDomain =
        (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';
    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('${ecomBaseUrl}wishlist/toggle');
      final body = jsonEncode({
        'domain': effectiveDomain,
        'product_id': productId.toString(),
      });

      final res = await _client.post(url, headers: headers, body: body);
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint('WishlistService toggleWishlist error: $e');
    }
    return {'status': false, 'message': 'Network error'};
  }
}
