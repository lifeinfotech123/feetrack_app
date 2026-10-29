import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../controllers/conversations_controller.dart';
import '../models/chat_message_model.dart';
import 'live_chat_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  final String? domain;

  const ConversationsListScreen({super.key, this.domain});

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  late final ConversationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ConversationsController());
    _controller.fetchConversations(domain: widget.domain);
  }

  void _openChat(dynamic conv) {
    final chatUser = ChatUserModel(
      id: '${conv.type}_${conv.shopId ?? conv.counterpartId ?? 0}',
      name: conv.name,
      role: conv.typeLabel,
      avatar: conv.avatar ?? '',
      type: conv.type,
      shopId: conv.shopId,
      sellerId: conv.sellerId,
      phone: conv.phone,
      isOnline: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveChatScreen(
          user: chatUser,
          domain: widget.domain,
        ),
      ),
    ).then((_) {
      _controller.fetchConversations(domain: widget.domain);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        title: const Text(
          "Messages & Support",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardBg,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : blackColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh chats",
            onPressed: () =>
                _controller.fetchConversations(domain: widget.domain),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: cardBg,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF282836)
                    : const Color(0xFFF1F1F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller.searchController,
                onChanged: (val) => _controller.setSearch(val),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : blackColor,
                ),
                decoration: InputDecoration(
                  hintText: "Search conversations, stores, support...",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : blackColor40,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: isDark ? Colors.white54 : blackColor60,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Unread summary banner (if any unread)
          Obx(() {
            final unread = _controller.unreadCount.value;
            if (unread.totalUnread <= 0) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mark_chat_unread_rounded,
                      color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You have ${unread.totalUnread} unread message${unread.totalUnread > 1 ? 's' : ''}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Conversation List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value &&
                  _controller.conversations.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              final list = _controller.filteredConversations;

              if (list.isEmpty) {
                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () =>
                      _controller.fetchConversations(domain: widget.domain),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 64,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black26,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No conversations yet",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : blackColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Start a chat with In-House Support\nor your favorite store!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white54
                                      : blackColor60,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                onPressed: () {
                                  // Open direct chat with In-House Support Team
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LiveChatScreen(
                                        user: ChatUserModel(
                                          id: 'admin_support',
                                          name: 'In-House Support Team',
                                          role: 'Customer Support',
                                          type: 'admin',
                                          isOnline: true,
                                        ),
                                        domain: widget.domain,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.support_agent_rounded,
                                    color: Colors.white, size: 18),
                                label: const Text(
                                  "Chat with Support",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: () =>
                    _controller.fetchConversations(domain: widget.domain),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final conv = list[index];
                    final bool isAdmin = conv.type == 'admin';

                    return Material(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      elevation: 0.5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _openChat(conv),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Avatar with Badge
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: isAdmin
                                        ? const Color(0xFFE8F5E9)
                                        : primaryColor.withValues(alpha: 0.12),
                                    child: (conv.avatar != null &&
                                            conv.avatar!.isNotEmpty)
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: conv.avatar!,
                                              width: 52,
                                              height: 52,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, __, ___) => Icon(
                                                isAdmin
                                                    ? Icons.support_agent_rounded
                                                    : Icons.store_rounded,
                                                color: isAdmin
                                                    ? const Color(0xFF2E7D32)
                                                    : primaryColor,
                                                size: 28,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            isAdmin
                                                ? Icons.support_agent_rounded
                                                : Icons.store_rounded,
                                            color: isAdmin
                                                ? const Color(0xFF2E7D32)
                                                : primaryColor,
                                            size: 28,
                                          ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        color: successColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cardBg,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 14),

                              // Info & Last message
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            conv.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: isDark
                                                  ? Colors.white
                                                  : blackColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (conv.lastMessage?.timeAgo !=
                                                null &&
                                            conv.lastMessage!.timeAgo
                                                .isNotEmpty)
                                          Text(
                                            conv.lastMessage!.timeAgo,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? Colors.white38
                                                  : blackColor40,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isAdmin
                                                ? const Color(0xFF00C853)
                                                    .withValues(alpha: 0.12)
                                                : primaryColor
                                                    .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            conv.typeLabel,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isAdmin
                                                  ? const Color(0xFF00C853)
                                                  : primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            conv.lastMessage?.message ??
                                                "Tap to start chatting",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: conv.unreadCount > 0
                                                  ? (isDark
                                                      ? Colors.white
                                                      : blackColor)
                                                  : (isDark
                                                      ? Colors.white60
                                                      : blackColor60),
                                              fontWeight: conv.unreadCount > 0
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (conv.unreadCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: const BoxDecoration(
                                              color: primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              "${conv.unreadCount}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        tooltip: "Live Support",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LiveChatScreen(
                user: ChatUserModel(
                  id: 'admin_support',
                  name: 'In-House Support Team',
                  role: 'Customer Support',
                  type: 'admin',
                  isOnline: true,
                ),
                domain: widget.domain,
              ),
            ),
          ).then((_) {
            _controller.fetchConversations(domain: widget.domain);
          });
        },
        child: const Icon(Icons.chat_bubble_outline_rounded,
            color: Colors.white),
      ),
    );
  }
}

