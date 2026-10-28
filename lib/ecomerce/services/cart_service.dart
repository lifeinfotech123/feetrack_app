import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class CartService {
  final http.Client _client;

  CartService({http.Client? client}) : _client = client ?? http.Client();

  /// Add to Cart API (POST api/v1/ecommerce/cart/add)
  Future<Map<String, dynamic>?> addToCart({
    int? userId,
    required String domain,
    required int productId,
    required int shopId,
    int quantity = 1,
    String? variant,
    String? color,
    Map<String, dynamic>? choices,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_app_token') ?? prefs.getString('token') ?? '';

    int effectiveUserId = userId ?? 27;
    if (userId == null) {
      final storedId = prefs.get('user_app_id') ?? prefs.get('userId');
      if (storedId is int) {
        effectiveUserId = storedId;
      } else if (storedId is String) {
        effectiveUserId = int.tryParse(storedId) ?? 27;
      }
    }

    final uri = Uri.parse('$ecomBaseUrl$ecomCartAddEndpoint');
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> body = {
      'user_id': effectiveUserId,
      'domain': domain.isNotEmpty ? domain : 'e-team-12',
      'product_id': productId,
      'shop_id': shopId,
      'variant': variant ?? "Standard",
      'variation': variant ?? "Standard",
      if (color != null && color.isNotEmpty) 'color': color,
      'quantity': quantity,
      if (choices != null && choices.isNotEmpty) 'choices': choices,
    };

    debugPrint('=========================================');
    debugPrint('[ECOMMERCE ADD TO CART API]');
    debugPrint('URL: $uri');
    debugPrint('Headers: $headers');
    debugPrint('Body: ${jsonEncode(body)}');
    debugPrint('=========================================');

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint(
          'CartService addToCart Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('CartService addToCart Exception: $e');
    }
    return null;
  }
}
