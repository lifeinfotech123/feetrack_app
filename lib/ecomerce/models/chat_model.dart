// class ChatModel {
//   final int? id;
//   final int? conversationId;
//   final int? senderId;
//   final int? receiverId;
//   final String? message;
//   final String? type;
//   final String? attachment;
//   final bool? isRead;
//   final String? createdAt;
//   final String? updatedAt;
//   final Map<String, dynamic>? sender;
//   final Map<String, dynamic>? receiver;

//   ChatModel({
//     this.id,
//     this.conversationId,
//     this.senderId,
//     this.receiverId,
//     this.message,
//     this.type,
//     this.attachment,
//     this.isRead,
//     this.createdAt,
//     this.updatedAt,
//     this.sender,
//     this.receiver,
//   });

//   factory ChatModel.fromJson(Map<String, dynamic> json) {
//     return ChatModel(
//       id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
//       conversationId: json['conversation_id'] is int
//           ? json['conversation_id']
//           : int.tryParse(json['conversation_id']?.toString() ?? ''),
//       senderId: json['sender_id'] is int
//           ? json['sender_id']
//           : int.tryParse(json['sender_id']?.toString() ?? ''),
//       receiverId: json['receiver_id'] is int
//           ? json['receiver_id']
//           : int.tryParse(json['receiver_id']?.toString() ?? ''),
//       message: json['message']?.toString(),
//       type: json['type']?.toString(),
//       attachment: json['attachment']?.toString(),
//       isRead: json['is_read'] == true || json['is_read'] == 1,
//       createdAt: json['created_at']?.toString(),
//       updatedAt: json['updated_at']?.toString(),
//       sender: json['sender'] is Map<String, dynamic> ? json['sender'] : null,
//       receiver: json['receiver'] is Map<String, dynamic> ? json['receiver'] : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'conversation_id': conversationId,
//       'sender_id': senderId,
//       'receiver_id': receiverId,
//       'message': message,
//       'type': type,
//       'attachment': attachment,
//       'is_read': isRead,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'sender': sender,
//       'receiver': receiver,
//     };
//   }
// }

// class ConversationModel {
//   final int? id;
//   final int? userId;
//   final int? vendorId;
//   final int? shopId;
//   final String? domain;
//   final String? lastMessage;
//   final String? lastMessageAt;
//   final int? unreadCount;
//   final Map<String, dynamic>? user;
//   final Map<String, dynamic>? vendor;
//   final Map<String, dynamic>? shop;

//   ConversationModel({
//     this.id,
//     this.userId,
//     this.vendorId,
//     this.shopId,
//     this.domain,
//     this.lastMessage,
//     this.lastMessageAt,
//     this.unreadCount,
//     this.user,
//     this.vendor,
//     this.shop,
//   });

//   factory ConversationModel.fromJson(Map<String, dynamic> json) {
//     return ConversationModel(
//       id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
//       userId: json['user_id'] is int
//           ? json['user_id']
//           : int.tryParse(json['user_id']?.toString() ?? ''),
//       vendorId: json['vendor_id'] is int
//           ? json['vendor_id']
//           : int.tryParse(json['vendor_id']?.toString() ?? ''),
//       shopId: json['shop_id'] is int
//           ? json['shop_id']
//           : int.tryParse(json['shop_id']?.toString() ?? ''),
//       domain: json['domain']?.toString(),
//       lastMessage: json['last_message']?.toString() ?? json['message']?.toString(),
//       lastMessageAt: json['last_message_at']?.toString() ?? json['updated_at']?.toString(),
//       unreadCount: json['unread_count'] is int
//           ? json['unread_count']
//           : int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
//       user: json['user'] is Map<String, dynamic> ? json['user'] : null,
//       vendor: json['vendor'] is Map<String, dynamic> ? json['vendor'] : null,
//       shop: json['shop'] is Map<String, dynamic> ? json['shop'] : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'vendor_id': vendorId,
//       'shop_id': shopId,
//       'domain': domain,
//       'last_message': lastMessage,
//       'last_message_at': lastMessageAt,
//       'unread_count': unreadCount,
//       'user': user,
//       'vendor': vendor,
//       'shop': shop,
//     };
//   }
// }

// class ChatListResponse {
//   final bool status;
//   final String? message;
//   final List<ConversationModel> conversations;

//   ChatListResponse({
//     required this.status,
//     this.message,
//     required this.conversations,
//   });

//   factory ChatListResponse.fromJson(Map<String, dynamic> json) {
//     final List list = json['data'] is List
//         ? json['data']
//         : (json['conversations'] is List ? json['conversations'] : []);
//     return ChatListResponse(
//       status: json['status'] == true,
//       message: json['message']?.toString(),
//       conversations: list
//           .map((e) => ConversationModel.fromJson(Map<String, dynamic>.from(e)))
//           .toList(),
//     );
//   }
// }

// class ChatMessagesResponse {
//   final bool status;
//   final String? message;
//   final List<ChatModel> messages;

//   ChatMessagesResponse({
//     required this.status,
//     this.message,
//     required this.messages,
//   });

//   factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
//     final List list = json['data'] is List
//         ? json['data']
//         : (json['messages'] is List ? json['messages'] : []);
//     return ChatMessagesResponse(
//       status: json['status'] == true,
//       message: json['message']?.toString(),
//       messages: list
//           .map((e) => ChatModel.fromJson(Map<String, dynamic>.from(e)))
//           .toList(),
//     );
//   }
// }

class LastMessageModel {
  final String message;
  final bool hasAttachment;
  final bool sentByCustomer;
  final String createdAt;
  final String timeAgo;

  LastMessageModel({
    required this.message,
    this.hasAttachment = false,
    this.sentByCustomer = true,
    this.createdAt = '',
    this.timeAgo = '',
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      message: json['message']?.toString() ?? '',
      hasAttachment: json['has_attachment'] == true,
      sentByCustomer: json['sent_by_customer'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'has_attachment': hasAttachment,
      'sent_by_customer': sentByCustomer,
      'created_at': createdAt,
      'time_ago': timeAgo,
    };
  }
}

class ChatConversationItemModel {
  final String type; // 'admin' or 'vendor' or 'delivery_man'
  final String typeLabel;
  final int? counterpartId;
  final int? shopId;
  final int? sellerId;
  final String name;
  final String? avatar;
  final String? phone;
  final int unreadCount;
  final LastMessageModel? lastMessage;

  ChatConversationItemModel({
    required this.type,
    required this.typeLabel,
    this.counterpartId,
    this.shopId,
    this.sellerId,
    required this.name,
    this.avatar,
    this.phone,
    this.unreadCount = 0,
    this.lastMessage,
  });

  factory ChatConversationItemModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationItemModel(
      type: json['type']?.toString() ?? 'admin',
      typeLabel: json['type_label']?.toString() ??
          (json['type'] == 'vendor' ? 'Store / Vendor' : 'In-House Support'),
      counterpartId: json['counterpart_id'] is int
          ? json['counterpart_id']
          : int.tryParse(json['counterpart_id']?.toString() ?? ''),
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? ''),
      sellerId: json['seller_id'] is int
          ? json['seller_id']
          : int.tryParse(json['seller_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'Support',
      avatar: json['avatar']?.toString(),
      phone: json['phone']?.toString(),
      unreadCount: json['unread_count'] is int
          ? json['unread_count']
          : int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      lastMessage: json['last_message'] is Map<String, dynamic>
          ? LastMessageModel.fromJson(json['last_message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'type_label': typeLabel,
      'counterpart_id': counterpartId,
      'shop_id': shopId,
      'seller_id': sellerId,
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'unread_count': unreadCount,
      'last_message': lastMessage?.toJson(),
    };
  }
}

class CounterpartyModel {
  final String type;
  final String typeLabel;
  final int? shopId;
  final int? sellerId;
  final String name;
  final String? avatar;
  final String? phone;

  CounterpartyModel({
    required this.type,
    required this.typeLabel,
    this.shopId,
    this.sellerId,
    required this.name,
    this.avatar,
    this.phone,
  });

  factory CounterpartyModel.fromJson(Map<String, dynamic> json) {
    return CounterpartyModel(
      type: json['type']?.toString() ?? 'admin',
      typeLabel: json['type_label']?.toString() ?? 'Customer Support',
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? ''),
      sellerId: json['seller_id'] is int
          ? json['seller_id']
          : int.tryParse(json['seller_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'Support',
      avatar: json['avatar']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'type_label': typeLabel,
      'shop_id': shopId,
      'seller_id': sellerId,
      'name': name,
      'avatar': avatar,
      'phone': phone,
    };
  }
}

class ChatApiMessageItemModel {
  final int id;
  final String sender; // 'customer' or other
  final bool isCustomer;
  final String message;
  final List<dynamic> attachments;
  final bool isSeen;
  final String createdAt;
  final String timeAgo;

  ChatApiMessageItemModel({
    required this.id,
    required this.sender,
    required this.isCustomer,
    required this.message,
    this.attachments = const [],
    this.isSeen = false,
    required this.createdAt,
    this.timeAgo = '',
  });

  factory ChatApiMessageItemModel.fromJson(Map<String, dynamic> json) {
    return ChatApiMessageItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      sender: json['sender']?.toString() ?? 'customer',
      isCustomer: json['is_customer'] == true || json['sender'] == 'customer',
      message: json['message']?.toString() ?? '',
      attachments: json['attachments'] is List ? json['attachments'] : [],
      isSeen: json['is_seen'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'is_customer': isCustomer,
      'message': message,
      'attachments': attachments,
      'is_seen': isSeen,
      'created_at': createdAt,
      'time_ago': timeAgo,
    };
  }
}

class ChatUnreadCountModel {
  final int totalUnread;
  final int vendorUnread;
  final int deliveryManUnread;
  final int adminUnread;

  ChatUnreadCountModel({
    this.totalUnread = 0,
    this.vendorUnread = 0,
    this.deliveryManUnread = 0,
    this.adminUnread = 0,
  });

  factory ChatUnreadCountModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return ChatUnreadCountModel(
      totalUnread: parseInt(json['total_unread']),
      vendorUnread: parseInt(json['vendor_unread']),
      deliveryManUnread: parseInt(json['delivery_man_unread']),
      adminUnread: parseInt(json['admin_unread']),
    );
  }
}
