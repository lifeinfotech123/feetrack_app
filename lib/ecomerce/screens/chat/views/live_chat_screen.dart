import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../components/chat_active_dot.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';
import 'components/chat_bubble.dart';
import 'components/chat_input_field.dart';
import 'components/typing_indicator.dart';

class LiveChatScreen extends StatefulWidget {
  final ChatUserModel? user;
  final String? orderId;
  final String? domain;

  const LiveChatScreen({
    super.key,
    this.user,
    this.orderId,
    this.domain,
  });

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  late final ChatController _controller;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    // Unique controller tag to avoid collisions if opened multiple times
    _tag = 'chat_${widget.user?.type ?? "admin"}_${widget.user?.shopId ?? widget.orderId ?? DateTime.now().millisecondsSinceEpoch}';
    if (Get.isRegistered<ChatController>(tag: _tag)) {
      Get.delete<ChatController>(tag: _tag, force: true);
    }
    _controller = Get.put(
      ChatController(
        user: widget.user,
        initialOrderId: widget.orderId,
        domain: widget.domain,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<ChatController>(tag: _tag)) {
      Get.delete<ChatController>(tag: _tag, force: true);
    }
    super.dispose();
  }

  void _showHelpOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.phone_rounded, color: Color(0xFF2E7D32)),
                  ),
                  title: const Text("Call Helpline"),
                  subtitle: const Text("+91 1800-123-4567 (Toll Free)"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.snackbar(
                      "Helpline",
                      "Dialing customer care support...",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  ),
                  title: const Text("Clear Conversation"),
                  subtitle: const Text("Reset this chat history"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _controller.clearChat();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF13131A) : const Color(0xFFF7F8FA);
    final appBarBg = isDark ? const Color(0xFF1E1E28) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : blackColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Obx(() {
          final user = _controller.activeUser.value;
          return Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    child: user.avatar.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.avatar,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.person,
                              ),
                            ),
                          )
                        : const Icon(Icons.person),
                  ),
                  if (user.isOnline)
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: ChatActiveDot(),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : blackColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: user.isOnline ? successColor : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          user.isOnline ? "Online • ${user.role}" : "Offline",
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white60 : blackColor60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? Colors.white70 : blackColor80,
            ),
            onPressed: _showHelpOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Replies Suggestions
          _buildQuickRepliesBar(isDark),

          // Messages List View
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              final msgs = _controller.messages;
              if (msgs.isEmpty) {
                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () => _controller.fetchMessages(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 54,
                                color: isDark ? Colors.white24 : Colors.black26,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No messages yet.\nSay Hi to start the conversation!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : blackColor60,
                                  fontSize: 13,
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
                onRefresh: () => _controller.fetchMessages(),
                child: ListView.builder(
                  controller: _controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                  final msg = msgs[index];
                  final bool showDateHeader = index == 0 ||
                      !_isSameDay(
                        msgs[index - 1].timestamp,
                        msg.timestamp,
                      );

                  return ChatBubble(
                    message: msg,
                    showDateHeader: showDateHeader,
                  );
                },
              ),
            );
          }),
          ),

          // Live Typing Indicator
          Obx(() {
            if (_controller.isTyping.value) {
              return TypingIndicator(
                senderName: _controller.activeUser.value.name,
              );
            }
            return const SizedBox.shrink();
          }),

          // Chat Input Area
          ChatInputField(controller: _controller),
        ],
      ),
    );
  }

  Widget _buildQuickRepliesBar(bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _controller.quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final query = _controller.quickReplies[index];
          return ActionChip(
            label: Text(
              query,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor:
                isDark ? const Color(0xFF222230) : Colors.white,
            side: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0.5,
            onPressed: () {
              // Strip emoji from beginning if present for cleaner message or send as is
              _controller.sendMessage(textOverride: query);
            },
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}