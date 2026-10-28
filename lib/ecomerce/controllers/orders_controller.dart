import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/order_model.dart';

class OrdersController extends GetxController {
  final http.Client _client = http.Client();

  final RxList<OrderListItemModel> orders = <OrderListItemModel>[].obs;
  final RxList<OrderListItemModel> filteredOrders = <OrderListItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedFilter =
      'All'.obs; // All, Food, eCommerce, Pending, Delivered, Cancelled
  final RxString searchQuery = ''.obs;
  final RxInt totalCount = 0.obs;

  // Selected Order Detail
  final Rx<OrderDetailsDataModel?> currentOrderDetail =
      Rx<OrderDetailsDataModel?>(null);
  final RxBool isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ??
        prefs.getString('user_app_token') ??
        '';
  }

  /// 1. Fetch Orders List
  /// GET api/v1/ecommerce/orders/list
  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('${ecomBaseUrl}orders/list');
      final res = await _client.get(url, headers: headers);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final dynamic data = decoded['data'];

        List rawList = [];
        int total = 0;

        if (data is Map<String, dynamic>) {
          total = data['total_orders'] is int
              ? data['total_orders']
              : int.tryParse(data['total_orders']?.toString() ?? '0') ?? 0;
          if (data['orders'] is List) {
            rawList = data['orders'];
          }
        } else if (data is List) {
          rawList = data;
          total = rawList.length;
        }

        final List<OrderListItemModel> parsed = [];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            parsed.add(OrderListItemModel.fromJson(item));
          }
        }

        orders.assignAll(parsed);
        totalCount.value = total > 0 ? total : parsed.length;
        applyFilters();
      } else {
        errorMessage.value = 'Failed to load orders (${res.statusCode})';
      }
    } catch (e) {
      debugPrint('OrdersController fetchOrders error: $e');
      errorMessage.value = 'Error loading orders: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  void setSearch(String query) {
    searchQuery.value = query.trim().toLowerCase();
    applyFilters();
  }

  void applyFilters() {
    var list = List<OrderListItemModel>.from(orders);

    // 1. Filter by Category / Type / Status
    final f = selectedFilter.value.toLowerCase();
    if (f == 'food') {
      list = list.where((o) => o.isFood).toList();
    } else if (f == 'ecommerce') {
      list = list.where((o) => !o.isFood).toList();
    } else if (f == 'pending') {
      list = list
          .where((o) =>
              o.orderStatus.toLowerCase() == 'pending' ||
              o.orderStatus.toLowerCase() == 'confirmed')
          .toList();
    } else if (f == 'delivered') {
      list = list
          .where((o) => o.orderStatus.toLowerCase() == 'delivered')
          .toList();
    } else if (f == 'canceled' || f == 'cancelled') {
      list = list
          .where((o) =>
              o.orderStatus.toLowerCase() == 'canceled' ||
              o.orderStatus.toLowerCase() == 'cancelled' ||
              o.orderStatus.toLowerCase() == 'returned')
          .toList();
    }

    // 2. Filter by Search Query (Order ID, Vendor, Domain)
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value;
      list = list.where((o) {
        final idStr = o.orderId.toString();
        final vendorStr = o.vendor.toLowerCase();
        final domainStr = o.domain.toLowerCase();
        final statusStr = o.orderStatus.toLowerCase();
        return idStr.contains(q) ||
            vendorStr.contains(q) ||
            domainStr.contains(q) ||
            statusStr.contains(q);
      }).toList();
    }

    filteredOrders.assignAll(list);
  }

  /// 2. Fetch Single Order Details
  /// GET api/v1/ecommerce/orders/details?store={storeDomain}&order_id={orderId}
  Future<OrderDetailsDataModel?> fetchOrderDetails(
    int orderId, {
    String? storeDomain,
  }) async {
    isDetailLoading.value = true;
    currentOrderDetail.value = null;

    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      String query = 'order_id=$orderId';
      if (storeDomain != null && storeDomain.isNotEmpty) {
        query = 'store=$storeDomain&order_id=$orderId';
      }

      final url = Uri.parse('${ecomBaseUrl}orders/details?$query');
      final res = await _client.get(url, headers: headers);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['status'] == true &&
            decoded['data'] is Map<String, dynamic>) {
          final parsed = OrderDetailsDataModel.fromJson(decoded['data']);
          currentOrderDetail.value = parsed;
          return parsed;
        }
      }
    } catch (e) {
      debugPrint('OrdersController fetchOrderDetails error: $e');
    } finally {
      isDetailLoading.value = false;
    }
    return null;
  }

  /// Get invoice URL (with auth)
  Future<String?> fetchInvoiceUrl(int orderId, {String? domain}) async {
    try {
      final token = await _getToken();
      final d = (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';
      final url = Uri.parse('${ecomBaseUrl}orders/invoice?domain=$d&order_id=$orderId');
      final res = await _client.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['status'] == true) {
          final pdfUrl = decoded['data']?['invoice']?['download_pdf_url']?.toString();
          if (pdfUrl != null && pdfUrl.isNotEmpty) return pdfUrl;
          // fallback to same url with download
          return '${ecomBaseUrl}orders/invoice?domain=$d&order_id=$orderId&download=1';
        }
      }
    } catch (e) {
      debugPrint('OrdersController fetchInvoiceUrl error: $e');
    }
    return null;
  }

  Future<String> getAuthToken() async => _getToken();

  /// Cancel Order
  Future<Map<String, dynamic>?> cancelOrder({
    required int orderId,
    String? domain,
    String cause = 'Changed mind',
  }) async {
    try {
      final token = await _getToken();
      final d = (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';
      final url = Uri.parse('${ecomBaseUrl}orders/cancel');
      final body = {
        'domain': d,
        'order_id': orderId,
        'cause': cause,
      };
      final res = await _client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        return decoded;
      }
    } catch (e) {
      debugPrint('OrdersController cancelOrder error: $e');
    }
    return null;
  }

  /// Reorder - Add items from order to cart
  Future<Map<String, dynamic>?> reorder({
    required int orderId,
    String? domain,
    bool clearCart = true,
  }) async {
    try {
      final token = await _getToken();
      final d = (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';
      final url = Uri.parse('${ecomBaseUrl}orders/reorder');
      final body = {
        'domain': d,
        'order_id': orderId,
        'clear_cart': clearCart,
      };
      final res = await _client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        return decoded;
      }
    } catch (e) {
      debugPrint('OrdersController reorder error: $e');
    }
    return null;
  }
}
