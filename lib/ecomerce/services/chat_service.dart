// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../constants.dart';

// class ChatService {
//   final http.Client _client;

//   ChatService({http.Client? client}) : _client = client ?? http.Client();

//   final Map<String, String> _headers = const {
//     'Accept': 'application/json',
//     'Content-Type': 'application/json',
//   };

//   Future<String> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return (prefs.getString('token') ??
//             prefs.getString('user_app_token') ??
//             prefs.getString('auth_token') ??
//             '')
//         .trim();
//   }

//   Future<Map<String, dynamic>?> getChats({String? domain}) async {
//     final token = await _getToken();
//     final headers = {..._headers};
//     if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

//     final queryParams = <String, String>{};
//     if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;

//     Uri uri = Uri.parse('${ecomBaseUrl}chat/chats');
//     if (queryParams.isNotEmpty) {
//       uri = uri.replace(queryParameters: queryParams);
//     }

//     try {
//       final response = await _client.get(uri, headers: headers);
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       debugPrint('ChatService getChats Exception: $e');
//     }
//     return null;
//   }

//   Future<Map<String, dynamic>?> getMessages({
//     required int conversationId,
//     String? domain,
//   }) async {
//     final token = await _getToken();
//     final headers = {..._headers};
//     if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

//     final queryParams = <String, String>{};
//     if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;

//     Uri uri = Uri.parse('${ecomBaseUrl}chat/messages/$conversationId');
//     if (queryParams.isNotEmpty) {
//       uri = uri.replace(queryParameters: queryParams);
//     }

//     try {
//       final response = await _client.get(uri, headers: headers);
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       debugPrint('ChatService getMessages Exception: $e');
//     }
//     return null;
//   }

//   Future<Map<String, dynamic>?> sendMessage({
//     required int conversationId,
//     required String message,
//     String? domain,
//   }) async {
//     final token = await _getToken();
//     final headers = {..._headers};
//     if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

//     final uri = Uri.parse('${ecomBaseUrl}chat/send-message');
//     final body = {
//       'conversation_id': conversationId,
//       'message': message,
//       if (domain != null && domain.isNotEmpty) 'domain': domain,
//     };

//     try {
//       final response = await _client.post(uri, headers: headers, body: jsonEncode(body));
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return jsonDecode(response.body);
//       }
//       return jsonDecode(response.body);
//     } catch (e) {
//       debugPrint('ChatService sendMessage Exception: $e');
//     }
//     return null;
//   }

//   Future<Map<String, dynamic>?> startConversation({
//     String? vendorId,
//     String? shopId,
//     String? domain,
//     String? message,
//   }) async {
//     final token = await _getToken();
//     final headers = {..._headers};
//     if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

//     final uri = Uri.parse('${ecomBaseUrl}chat/start-conversation');
//     final body = {
//       if (vendorId != null) 'vendor_id': vendorId,
//       if (shopId != null) 'shop_id': shopId,
//       if (domain != null && domain.isNotEmpty) 'domain': domain,
//       if (message != null && message.isNotEmpty) 'message': message,
//     };

//     try {
//       final response = await _client.post(uri, headers: headers, body: jsonEncode(body));
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return jsonDecode(response.body);
//       }
//       return jsonDecode(response.body);
//     } catch (e) {
//       debugPrint('ChatService startConversation Exception: $e');
//     }
//     return null;
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/ecomerce/models/chat_model.dart';
import '../constants.dart';

class ChatService {
  final http.Client _client;

  ChatService({http.Client? client}) : _client = client ?? http.Client();

  String _getToken(SharedPreferences prefs) {
    final token = prefs.getString('token') ??
        prefs.getString('user_app_token') ??
        prefs.getString('auth_token') ??
        '';
    return token.trim();
  }

  String _getDomain(String? domain) {
    if (domain != null && domain.trim().isNotEmpty) {
      return domain.trim();
    }
    return 'e-team-12';
  }

  Map<String, String> _buildHeaders(String token) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 1. Get Chat Conversations List (POST/GET api/v1/ecommerce/chat/conversations?domain=...)
  Future<List<ChatConversationItemModel>> getConversations({
    String? domain,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);
    final effectiveDomain = _getDomain(domain);

    final uri = Uri.parse(
        '$ecomBaseUrl$ecomChatConversationsEndpoint?domain=$effectiveDomain');
    final headers = _buildHeaders(token);

    try {
      // User specifies method == post for chat/conversations
      var response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode({'domain': effectiveDomain}),
      );

      // Fallback to GET if method not allowed
      if (response.statusCode == 405) {
        response = await _client.get(uri, headers: headers);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] != null) {
          final data = decoded['data'];
          final convList = data['conversations'];
          if (convList is List) {
            return convList
                .map((item) => ChatConversationItemModel.fromJson(item))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching chat conversations: $e");
      return [];
    }
  }

  /// 2. Get Messages for a conversation (GET api/v1/ecommerce/chat/messages?domain=...&type=...&shop_id=...)
  Future<Map<String, dynamic>> getMessages({
    String? domain,
    required String type,
    int? shopId,
    int? sellerId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);
    final effectiveDomain = _getDomain(domain);

    final queryParams = <String, String>{
      'domain': effectiveDomain,
      'type': type,
    };
    if (shopId != null && shopId > 0) {
      queryParams['shop_id'] = shopId.toString();
    }
    if (sellerId != null && sellerId > 0) {
      queryParams['seller_id'] = sellerId.toString();
    }

    final uri = Uri.parse(
      '$ecomBaseUrl$ecomChatMessagesEndpoint?${Uri(queryParameters: queryParams).query}',
    );
    final headers = _buildHeaders(token);

    try {
      final response = await _client.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] != null) {
          final data = decoded['data'];
          CounterpartyModel? counterparty;
          if (data['counterparty'] is Map<String, dynamic>) {
            counterparty = CounterpartyModel.fromJson(data['counterparty']);
          }

          final msgsJson = data['messages'];
          final List<ChatApiMessageItemModel> messages = [];
          if (msgsJson is List) {
            for (final m in msgsJson) {
              if (m is Map<String, dynamic>) {
                messages.add(ChatApiMessageItemModel.fromJson(m));
              }
            }
          }

          return {
            'counterparty': counterparty,
            'messages': messages,
            'total_messages': data['total_messages'] ?? messages.length,
          };
        }
      }
      return {'messages': <ChatApiMessageItemModel>[], 'total_messages': 0};
    } catch (e) {
      debugPrint("Error fetching chat messages: $e");
      return {'messages': <ChatApiMessageItemModel>[], 'total_messages': 0};
    }
  }

  /// 3. Send Message (POST api/v1/ecommerce/chat/send)
  Future<bool> sendMessage({
    String? domain,
    required String type, // 'admin' or 'vendor'
    int? shopId,
    int? sellerId,
    required String message,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);
    final effectiveDomain = _getDomain(domain);

    final uri = Uri.parse('$ecomBaseUrl$ecomChatSendEndpoint');

    try {
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync()) {
        // Multipart request for image attachment
        final request = http.MultipartRequest('POST', uri);
        if (token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.headers['Accept'] = 'application/json';

        request.fields['domain'] = effectiveDomain;
        request.fields['type'] = type;
        request.fields['message'] = message;
        if (shopId != null && shopId > 0) {
          request.fields['shop_id'] = shopId.toString();
        }
        if (sellerId != null && sellerId > 0) {
          request.fields['seller_id'] = sellerId.toString();
        }

        request.files.add(
          await http.MultipartFile.fromPath('attachments[]', imagePath),
        );

        final streamed = await _client.send(request);
        final res = await http.Response.fromStream(streamed);
        return res.statusCode >= 200 && res.statusCode < 300;
      } else {
        // Standard JSON POST
        final headers = _buildHeaders(token);
        final body = <String, dynamic>{
          'domain': effectiveDomain,
          'type': type,
          'message': message,
          if (shopId != null && shopId > 0) 'shop_id': shopId,
          if (sellerId != null && sellerId > 0) 'seller_id': sellerId,
        };

        final response = await _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
        return response.statusCode >= 200 && response.statusCode < 300;
      }
    } catch (e) {
      debugPrint("Error sending chat message: $e");
      return false;
    }
  }

  /// 4. Mark Messages as Read (GET / POST api/v1/ecommerce/chat/read)
  Future<bool> markMessagesAsRead({
    String? domain,
    int? shopId,
    String? type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);
    final effectiveDomain = _getDomain(domain);

    final queryParams = <String, String>{
      'domain': effectiveDomain,
      if (shopId != null && shopId > 0) 'shop_id': shopId.toString(),
      if (type != null) 'type': type,
    };

    final uri = Uri.parse(
      '$ecomBaseUrl$ecomChatReadEndpoint?${Uri(queryParameters: queryParams).query}',
    );
    final headers = _buildHeaders(token);

    try {
      // User says method == get with body: {"domain": "e-team-12", "shop_id": 1}
      // In HTTP, GET with body is often not accepted by servers, so we pass query params and try GET then POST
      var response = await _client.get(uri, headers: headers);
      if (response.statusCode == 405 || response.statusCode >= 400) {
        response = await _client.post(
          Uri.parse('$ecomBaseUrl$ecomChatReadEndpoint'),
          headers: headers,
          body: jsonEncode({
            'domain': effectiveDomain,
            if (shopId != null) 'shop_id': shopId,
            if (type != null) 'type': type,
          }),
        );
      }
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint("Error marking messages as read: $e");
      return false;
    }
  }

  /// 5. Get Unread Count (GET api/v1/ecommerce/chat/unread-count?domain=...)
  Future<ChatUnreadCountModel> getUnreadCount({String? domain}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);
    final effectiveDomain = _getDomain(domain);

    final uri = Uri.parse(
        '$ecomBaseUrl$ecomChatUnreadCountEndpoint?domain=$effectiveDomain');
    final headers = _buildHeaders(token);

    try {
      final response = await _client.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] != null) {
          return ChatUnreadCountModel.fromJson(decoded['data']);
        }
      }
      return ChatUnreadCountModel();
    } catch (e) {
      debugPrint("Error fetching unread count: $e");
      return ChatUnreadCountModel();
    }
  }
}
