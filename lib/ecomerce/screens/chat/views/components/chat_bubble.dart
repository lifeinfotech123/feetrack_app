import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../constants.dart';
import '../../models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool showDateHeader;

  const ChatBubble({
    super.key,
    required this.message,
    this.showDateHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment:
          message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showDateHeader) _buildDateHeader(message.timestamp, isDark),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            mainAxisAlignment:
                message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.76,
                  ),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? primaryColor
                        : (isDark
                            ? const Color(0xFF242432)
                            : const Color(0xFFF3F4F8)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isMe ? 16 : 4),
                      bottomRight: Radius.circular(message.isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: message.type == MessageType.image
                      ? const EdgeInsets.all(5)
                      : const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                  child: Column(
                    crossAxisAlignment: message.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Order Card Message
                      if (message.type == MessageType.orderCard)
                        _buildOrderCard(context, isDark),

                      // Image Message
                      if (message.type == MessageType.image)
                        _buildImageContent(context),

                      // Text Message
                      if (message.message.isNotEmpty &&
                          message.type != MessageType.orderCard)
                        Text(
                          message.message,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: message.isMe
                                ? Colors.white
                                : (isDark ? Colors.white : blackColor),
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Timestamp & Status ticks
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('hh:mm a').format(message.timestamp),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: message.isMe
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : (isDark ? Colors.white54 : blackColor60),
                            ),
                          ),
                          if (message.isMe) ...[
                            const SizedBox(width: 4),
                            _buildStatusIcon(message.status),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date, bool isDark) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = "Today";
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = "Yesterday";
    } else {
      label = DateFormat('MMM dd, yyyy').format(date);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFEBEBF0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : blackColor60,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: message.isMe
            ? Colors.white.withValues(alpha: 0.15)
            : (isDark ? Colors.black26 : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: message.isMe
              ? Colors.white24
              : (isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                size: 16,
                color: primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                "Order #${message.orderId ?? 'N/A'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: message.isMe
                      ? Colors.white
                      : (isDark ? Colors.white : blackColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message.message,
            style: TextStyle(
              fontSize: 12,
              color: message.isMe
                  ? Colors.white.withValues(alpha: 0.9)
                  : (isDark ? Colors.white70 : blackColor80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    final imagePath = message.localImagePath;
    final imageUrl = message.imageUrl;

    Widget imageWidget;
    if (imagePath != null && File(imagePath).existsSync()) {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
      );
    } else {
      imageWidget = const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 220,
          minWidth: 160,
        ),
        child: imageWidget,
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(
          Icons.access_time_rounded,
          size: 12,
          color: Colors.white70,
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.check_rounded,
          size: 14,
          color: Colors.white70,
        );
      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all_rounded,
          size: 14,
          color: Colors.white70,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all_rounded,
          size: 14,
          color: Color(0xFF64FFDA), // Bright cyan read tick
        );
    }
  }
}
