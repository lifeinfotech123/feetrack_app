import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/support_ticket_model.dart';

class SupportTicketService {
  final http.Client _client;

  SupportTicketService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseEndpoint = "support-tickets";

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('token') ??
            prefs.getString('user_app_token') ??
            prefs.getString('auth_token') ??
            '')
        .trim();
  }

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (requireAuth) {
      final token = await _getToken();
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// 1. Fetch Support Ticket Types & Metadata
  /// GET api/v1/ecommerce/support-tickets/types?domain=e-team-12
  Future<SupportTicketMetadataModel?> getTicketTypes({
    String domain = 'e-team-12',
  }) async {
    final url = Uri.parse('$ecomBaseUrl$_baseEndpoint/types?domain=$domain');
    try {
      final headers = await _getHeaders(requireAuth: false);
      final response = await _client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return SupportTicketMetadataModel.fromJson(
            Map<String, dynamic>.from(body['data']),
          );
        }
      }
    } catch (e) {
      debugPrint('SupportTicketService getTicketTypes Exception: $e');
    }
    return null;
  }

  /// 2. Fetch User's Support Tickets List
  /// GET api/v1/ecommerce/support-tickets?domain=e-team-12
  Future<List<SupportTicketModel>> getTickets({
    String domain = 'e-team-12',
  }) async {
    final url = Uri.parse('$ecomBaseUrl$_baseEndpoint?domain=$domain');
    try {
      final headers = await _getHeaders(requireAuth: true);
      final response = await _client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final data = body['data'];
          if (data['tickets'] is List) {
            final List list = data['tickets'];
            return list
                .map((item) =>
                    SupportTicketModel.fromJson(Map<String, dynamic>.from(item)))
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('SupportTicketService getTickets Exception: $e');
    }
    return [];
  }

  /// 3. Fetch Single Ticket Details & Conversations
  /// GET api/v1/ecommerce/support-tickets/details?domain=e-team-12&ticket_id=...
  Future<SupportTicketDetailsModel?> getTicketDetails({
    required int ticketId,
    String domain = 'e-team-12',
  }) async {
    final url = Uri.parse(
        '$ecomBaseUrl$_baseEndpoint/details?domain=$domain&ticket_id=$ticketId');
    try {
      final headers = await _getHeaders(requireAuth: true);
      final response = await _client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return SupportTicketDetailsModel.fromJson(
            Map<String, dynamic>.from(body['data']),
          );
        }
      }
    } catch (e) {
      debugPrint('SupportTicketService getTicketDetails Exception: $e');
    }
    return null;
  }

  /// 4. Create Support Ticket
  /// POST api/v1/ecommerce/support-tickets/create
  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String type,
    required String priority,
    required String description,
    int? orderId,
    String domain = 'e-team-12',
  }) async {
    final url = Uri.parse('$ecomBaseUrl$_baseEndpoint/create');
    final payload = <String, dynamic>{
      'domain': domain,
      'subject': subject,
      'type': type,
      'priority': priority.toLowerCase(),
      'description': description,
    };
    if (orderId != null && orderId > 0) {
      payload['order_id'] = orderId;
    }

    try {
      final headers = await _getHeaders(requireAuth: true);
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': body['status'] == true,
          'message': body['message'] ?? 'Ticket created successfully',
          'data': body['data'] != null
              ? SupportTicketModel.fromJson(Map<String, dynamic>.from(body['data']))
              : null,
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to create ticket',
        };
      }
    } catch (e) {
      debugPrint('SupportTicketService createTicket Exception: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// 5. Reply to Support Ticket
  /// POST api/v1/ecommerce/support-tickets/reply
  Future<Map<String, dynamic>> replyTicket({
    required int ticketId,
    required String message,
    String domain = 'e-team-12',
  }) async {
    final url = Uri.parse('$ecomBaseUrl$_baseEndpoint/reply');
    final payload = <String, dynamic>{
      'domain': domain,
      'ticket_id': ticketId,
      'message': message,
    };

    try {
      final headers = await _getHeaders(requireAuth: true);
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': body['status'] == true,
          'message': body['message'] ?? 'Reply sent successfully',
          'data': body['data'] != null
              ? TicketConversationModel.fromJson(
                  Map<String, dynamic>.from(body['data']),
                )
              : null,
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to send reply',
        };
      }
    } catch (e) {
      debugPrint('SupportTicketService replyTicket Exception: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

