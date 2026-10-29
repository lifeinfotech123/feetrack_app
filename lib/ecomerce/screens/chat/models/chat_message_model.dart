import 'package:flutter/material.dart';

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, image, orderCard }

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final MessageStatus status;
  final MessageType type;
  final String? imageUrl;
  final String? localImagePath;
  
  // Optional Order Context Info
  final String? orderId;
  final String? orderStatus;
  final String? orderAmount;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.imageUrl,
    this.localImagePath,
    this.orderId,
    this.orderStatus,
    this.orderAmount,
  });

  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? timestamp,
    bool? isMe,
    MessageStatus? status,
    MessageType? type,
    String? imageUrl,
    String? localImagePath,
    String? orderId,
    String? orderStatus,
    String? orderAmount,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      status: status ?? this.status,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      orderId: orderId ?? this.orderId,
      orderStatus: orderStatus ?? this.orderStatus,
      orderAmount: orderAmount ?? this.orderAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_me': isMe,
      'status': status.name,
      'type': type.name,
      'image_url': imageUrl,
      'order_id': orderId,
      'order_status': orderStatus,
      'order_amount': orderAmount,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      senderId: json['sender_id']?.toString() ?? '',
      senderName: json['sender_name']?.toString() ?? 'User',
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isMe: json['is_me'] == true,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.read,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      imageUrl: json['image_url'],
      orderId: json['order_id'],
      orderStatus: json['order_status'],
      orderAmount: json['order_amount'],
    );
  }
}

class ChatUserModel {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final bool isOnline;
  final String statusMessage;
  final String type; // 'admin' or 'vendor'
  final int? shopId;
  final int? sellerId;
  final String? phone;

  ChatUserModel({
    required this.id,
    required this.name,
    this.role = "Customer Support",
    this.avatar = "",
    this.isOnline = true,
    this.statusMessage = "Typically replies in minutes",
    this.type = "admin",
    this.shopId,
    this.sellerId,
    this.phone,
  });
}

