import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';
import 'wishlist_controller.dart';

class ProfileController extends GetxController {
  final http.Client _client = http.Client();

  final Rx<UserProfileModel?> profile = Rx<UserProfileModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Dynamic Metrics
  final RxInt totalOrders = 0.obs;
  final RxInt pendingOrders = 0.obs;
  final RxInt shippedOrders = 0.obs;
  final RxInt deliveredOrders = 0.obs;
  final RxInt returnOrders = 0.obs;
  final RxInt wishlistCount = 0.obs;
  final RxInt couponsCount = 3.obs;
  final RxDouble walletBalance = 0.0.obs;

  static const String baseUrl = 'https://orderknow.com/';

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('user_app_token') ?? '';
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    errorMessage.value = '';

    await Future.wait([
      fetchUserProfile(),
      fetchOrdersSummary(),
      WishlistController.instance.fetchWishlist(),
    ]);

    wishlistCount.value = WishlistController.instance.wishlistItems.length;

    isLoading.value = false;
  }

  /// 1. Fetch User Profile & Wallet Details
  /// GET api/v1/auth/profile
  Future<void> fetchUserProfile() async {
    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('${baseUrl}api/v1/auth/profile');
      final res = await _client.get(url, headers: headers);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['status'] == true && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;
          final parsed = UserProfileModel.fromJson(data);
          profile.value = parsed;

          // Update dynamic wallet balance
          walletBalance.value = parsed.walletAmount;
        }
      } else {
        debugPrint(
            'ProfileController fetchUserProfile error: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('ProfileController fetchUserProfile Exception: $e');
    }
  }

  /// 2. Fetch Orders Summary for Dynamic Status Counters
  /// GET api/v1/ecommerce/orders
  Future<void> fetchOrdersSummary() async {
    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('${baseUrl}api/v1/ecommerce/orders');
      final res = await _client.get(url, headers: headers);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final dynamic data = decoded['data'];

        List ordersList = [];
        int total = 0;

        if (data is Map<String, dynamic>) {
          total = data['total_orders'] is int
              ? data['total_orders']
              : int.tryParse(data['total_orders']?.toString() ?? '0') ?? 0;
          if (data['orders'] is List) {
            ordersList = data['orders'];
          }
        } else if (data is List) {
          ordersList = data;
          total = ordersList.length;
        }

        totalOrders.value = total > 0 ? total : ordersList.length;

        int pending = 0;
        int shipped = 0;
        int delivered = 0;
        int returns = 0;

        for (final item in ordersList) {
          if (item is Map) {
            final status =
                (item['order_status'] ?? '').toString().toLowerCase();
            if (status == 'pending' || status == 'confirmed') {
              pending++;
            } else if (status == 'shipped' ||
                status == 'processing' ||
                status == 'out_for_delivery') {
              shipped++;
            } else if (status == 'delivered') {
              delivered++;
            } else if (status == 'canceled' ||
                status == 'cancelled' ||
                status == 'returned' ||
                status == 'failed') {
              returns++;
            }
          }
        }

        pendingOrders.value = pending;
        shippedOrders.value = shipped;
        deliveredOrders.value = delivered;
        returnOrders.value = returns;
      }
    } catch (e) {
      debugPrint('ProfileController fetchOrdersSummary Exception: $e');
    }
  }
}
