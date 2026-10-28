import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/top_slider_model.dart';

class TopSliderService {
  final http.Client _client;

  TopSliderService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Fetch Top Slider Banners (api/v1/ecommerce/top-slider)
  Future<List<TopSliderModel>> getTopSliders() async {
    final uri = Uri.parse('$ecomBaseUrl$ecomTopSliderEndpoint');
    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          return list
              .map((item) =>
                  TopSliderModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint(
            'TopSliderService getTopSliders Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('TopSliderService getTopSliders Exception: $e');
    }
    return [];
  }
}
