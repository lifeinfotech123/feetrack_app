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

  /// 1. Get Wishlist Items
  /// GET api/v1/ecommerce/wishlist?domain={domain}
  Future<List<WishlistItemModel>> getWishlist({String? domain}) async {
    final effectiveDomain = (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';
    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('${ecomBaseUrl}wishlist?domain=$effectiveDomain');
      final res = await _client.get(url, headers: headers);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['status'] == true && decoded['data'] is Map<String, dynamic>) {
          final data = decoded['data'] as Map<String, dynamic>;
          final rawItems = data['items'];
          if (rawItems is List) {
            return rawItems
                .whereType<Map<String, dynamic>>()
                .map((j) => WishlistItemModel.fromJson(j, defaultDomain: effectiveDomain))
                .toList();
          }
        }
      }
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
    final effectiveDomain = (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';
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
    final effectiveDomain = (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';
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
