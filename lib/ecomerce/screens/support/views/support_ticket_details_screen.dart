import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../controllers/support_ticket_controller.dart';
import '../../../models/support_ticket_model.dart';

class SupportTicketDetailsScreen extends StatefulWidget {
  final int ticketId;
  final SupportTicketModel? initialTicket;

  const SupportTicketDetailsScreen({
    super.key,
    required this.ticketId,
    this.initialTicket,
  });

  @override
  State<SupportTicketDetailsScreen> createState() =>
      _SupportTicketDetailsScreenState();
}

class _SupportTicketDetailsScreenState
    extends State<SupportTicketDetailsScreen> {
  late final SupportTicketController _controller;
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller = SupportTicketController.instance;
    _controller.fetchTicketDetails(widget.ticketId);

    _replyController.addListener(() {
      final can = _replyController.text.trim().isNotEmpty;
      if (can != _canSend) {
        setState(() {
          _canSend = can;
        });
      }
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF00C853);
      case 'resolved':
        return const Color(0xFF00B0FF);
      case 'closed':
      default:
        return const Color(0xFF757575);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFD32F2F);
      case 'high':
        return const Color(0xFFFF5722);
      case 'medium':
        return const Color(0xFFFFA000);
      case 'low':
      default:
        return const Color(0xFF1976D2);
    }
  }

  Future<void> _handleSendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    _replyController.clear();
    final success = await _controller.sendReply(
      ticketId: widget.ticketId,
      message: text,
    );

    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF101015) : const Color(0xFFF7F8FA);
    final cardBg = isDark ? const Color(0xFF1C1C24) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Obx(() {
          final ticket =
              _controller.currentTicketDetails.value?.ticket ?? widget.initialTicket;
          final title = ticket?.ticketNumber.isNotEmpty == true
              ? ticket!.ticketNumber
              : "#TK-${widget.ticketId.toString().padLeft(4, '0')}";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              if (ticket != null)
                Text(
                  ticket.type,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );
        }),
        actions: [
          Obx(() {
            final ticket =
                _controller.currentTicketDetails.value?.ticket ?? widget.initialTicket;
            if (ticket == null) return const SizedBox.shrink();

            final statusColor = _getStatusColor(ticket.status);
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        ticket.statusLabel.isNotEmpty
                            ? ticket.statusLabel
                            : ticket.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: Obx(() {
              if (_controller.isLoadingDetails.value &&
                  _controller.currentTicketDetails.value == null) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (_controller.detailsError.isNotEmpty &&
                  _controller.currentTicketDetails.value == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 54,
                        color: Color(0xFFE53935),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _controller.detailsError.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _controller.fetchTicketDetails(widget.ticketId),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final details = _controller.currentTicketDetails.value;
              final ticket = details?.ticket ?? widget.initialTicket;
              final conversations = details?.conversations ?? [];

              if (ticket == null) {
                return const Center(child: Text("Ticket details not found"));
              }

              return RefreshIndicator(
                onRefresh: () =>
                    _controller.fetchTicketDetails(widget.ticketId),
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(defaultPadding),
                  children: [
                    // Ticket Summary Card
                    _buildTicketHeaderCard(ticket, cardBg, isDark),
                    const SizedBox(height: 20),

                    // Conversation Header
                    Row(
                      children: [
                        const Icon(
                          Icons.forum_outlined,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Conversations (${conversations.length})",
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Conversation Messages List
                    if (conversations.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_top_rounded,
                              size: 20,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "No replies yet. Our support team has received your ticket and will respond shortly.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...conversations.map((msg) => _buildMessageBubble(
                            msg,
                            isDark,
                            cardBg,
                          )),

                    const SizedBox(height: 16),
                  ],
                ),
              );
            }),
          ),

          // Bottom Reply Input Bar
          _buildReplyBar(isDark, cardBg),
        ],
      ),
    );
  }

  Widget _buildTicketHeaderCard(
    SupportTicketModel ticket,
    Color cardBg,
    bool isDark,
  ) {
    final priorityColor = _getPriorityColor(ticket.priority);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          Text(
            ticket.subject,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          // Tags row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              // Issue Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262632)
                      : const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.type,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Priority Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 12,
                      color: priorityColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.priorityLabel.isNotEmpty
                          ? ticket.priorityLabel
                          : ticket.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Initial Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF22222E)
                  : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Initial Description:",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.description.isNotEmpty
                      ? ticket.description
                      : "No additional description provided.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Created at / Updated at
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(width: 4),
              Text(
                "Created: ${ticket.createdAt.isNotEmpty ? ticket.createdAt : (ticket.timeAgo.isNotEmpty ? ticket.timeAgo : 'Recently')}",
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    TicketConversationModel msg,
    bool isDark,
    Color cardBg,
  ) {
    final isCustomer = msg.isCustomer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCustomer) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF00C853),
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isCustomer
                    ? primaryColor
                    : (isDark ? const Color(0xFF22222E) : cardBg),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCustomer ? 16 : 4),
                  bottomRight: Radius.circular(isCustomer ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isCustomer
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.senderName.isNotEmpty
                        ? msg.senderName
                        : (isCustomer ? "You" : "Support Team"),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCustomer
                          ? Colors.white70
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.message,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: isCustomer
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.timeAgo.isNotEmpty
                        ? msg.timeAgo
                        : (msg.createdAt.isNotEmpty ? msg.createdAt : ""),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCustomer
                          ? Colors.white60
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCustomer) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildReplyBar(bool isDark, Color cardBg) {
    return Container(
      color: isDark ? const Color(0xFF16161E) : Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: "Type your reply here...",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF22222E)
                      : const Color(0xFFF1F3F6),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final isSending = _controller.isSendingReply.value;

              return InkWell(
                onTap: (_canSend && !isSending) ? _handleSendReply : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _canSend ? primaryColor : Colors.grey.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
