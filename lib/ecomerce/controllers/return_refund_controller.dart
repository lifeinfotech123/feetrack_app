import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/return_refund_model.dart';

class ReturnRefundController extends GetxController {
  final http.Client _client = http.Client();

  final RxList<ReturnRefundModel> refunds = <ReturnRefundModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ??
        prefs.getString('user_app_token') ??
        '';
  }

  Future<bool> requestRefund({
    required String domain,
    required int orderDetailsId,
    required String refundReason,
    String? paymentInfo,
  }) async {
    isSubmitting.value = true;
    try {
      final token = await _getToken();
      final url = Uri.parse('${ecomBaseUrl}refunds/request');
      final body = {
        'domain': domain,
        'order_details_id': orderDetailsId,
        'refund_reason': refundReason,
        if (paymentInfo != null && paymentInfo.isNotEmpty) 'payment_info': paymentInfo,
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
        if (decoded['status'] == true) {
          Get.snackbar('Success', decoded['message'] ?? 'Refund & return request submitted successfully.');
          return true;
        }
        Get.snackbar('Error', decoded['message'] ?? 'Failed to submit request');
        return false;
      }
      Get.snackbar('Error', 'Failed to submit request');
      return false;
    } catch (e) {
      debugPrint('ReturnRefundController requestRefund error: $e');
      Get.snackbar('Error', 'Something went wrong');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchRefunds({String? domain}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = await _getToken();
      final d = domain ?? 'e-team-12';
      final url = Uri.parse('${ecomBaseUrl}refunds?domain=$d');
      final res = await _client.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['status'] == true && decoded['data'] is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data['refunds'] is List) {
            final list = (data['refunds'] as List)
                .map((e) => e is Map<String, dynamic> ? ReturnRefundModel.fromJson(e) : null)
                .whereType<ReturnRefundModel>()
                .toList();
            refunds.assignAll(list);
          }
        } else if (decoded['status'] == true && decoded['data'] is List) {
          final list = (decoded['data'] as List)
              .map((e) => e is Map<String, dynamic> ? ReturnRefundModel.fromJson(e) : null)
              .whereType<ReturnRefundModel>()
              .toList();
          refunds.assignAll(list);
        }
      }
    } catch (e) {
      debugPrint('ReturnRefundController fetchRefunds error: $e');
      errorMessage.value = 'Failed to load refunds';
    } finally {
      isLoading.value = false;
    }
  }

  Future<ReturnRefundModel?> fetchRefundDetails(int refundId, {String? domain}) async {
    try {
      final token = await _getToken();
      final d = domain ?? 'e-team-12';
      final url = Uri.parse('${ecomBaseUrl}refunds?domain=$d&refund_id=$refundId');
      final res = await _client.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['status'] == true && decoded['data'] is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data['refunds'] is List && data['refunds'].isNotEmpty) {
            return ReturnRefundModel.fromJson(data['refunds'][0]);
          }
        }
      }
    } catch (e) {
      debugPrint('ReturnRefundController fetchRefundDetails error: $e');
    }
    return null;
  }
}
