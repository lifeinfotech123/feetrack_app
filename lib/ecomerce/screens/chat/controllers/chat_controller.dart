import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vlr/ecomerce/models/chat_model.dart';
import '../../../services/chat_service.dart';
import '../models/chat_message_model.dart';

class ChatController extends GetxController {
  final ChatUserModel initialUser;
  final String? initialOrderId;
  final String? domain;

  ChatController({
    ChatUserModel? user,
    this.initialOrderId,
    this.domain,
  }) : initialUser = user ??
            ChatUserModel(
              id: 'admin_support',
              name: 'In-House Support Team',
              role: 'Customer Support',
              avatar: '',
              isOnline: true,
              statusMessage: 'Typically replies instantly',
              type: 'admin',
            );

  final Uuid _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();

  late final Rx<ChatUserModel> activeUser;
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final RxBool isSendingImage = false.obs;
  final RxString currentUserId = 'user_me'.obs;
  final RxString currentUserName = 'Me'.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();

  Timer? _pollingTimer;

  // Quick reply prompt suggestions
  final List<String> quickReplies = [
    "📦 Track my order",
    "💳 Refund status",
    "📍 Change delivery address",
    "❌ Cancel my order",
    "🧑‍💼 Connect with live agent",
  ];

  @override
  void onInit() {
    super.onInit();
    activeUser = initialUser.obs;
    _loadCurrentUserInfo();
    fetchMessages();

    // Periodic polling every 5 seconds for incoming live messages
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollNewMessages();
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    scrollController.dispose();
    textController.dispose();
    super.onClose();
  }

  Future<void> _loadCurrentUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.get('user_app_id') ?? prefs.get('userId');
      if (id != null) {
        currentUserId.value = id.toString();
      }
      final name = prefs.getString('user_name') ?? prefs.getString('name');
      if (name != null && name.isNotEmpty) {
        currentUserName.value = name;
      }
    } catch (_) {}
  }

  /// 1. Fetch Messages from API 3: GET api/v1/ecommerce/chat/messages
  Future<void> fetchMessages({bool showLoader = true}) async {
    if (showLoader && messages.isEmpty) {
      isLoading.value = true;
    }
    try {
      final result = await _chatService.getMessages(
        domain: domain,
        type: activeUser.value.type,
        shopId: activeUser.value.shopId,
        sellerId: activeUser.value.sellerId,
      );

      final counterparty = result['counterparty'] as CounterpartyModel?;
      if (counterparty != null) {
        activeUser.value = ChatUserModel(
          id: '${counterparty.type}_${counterparty.shopId ?? 0}',
          name: counterparty.name.isNotEmpty
              ? counterparty.name
              : activeUser.value.name,
          role: counterparty.typeLabel,
          avatar: counterparty.avatar ?? activeUser.value.avatar,
          phone: counterparty.phone ?? activeUser.value.phone,
          type: counterparty.type,
          shopId: counterparty.shopId,
          sellerId: counterparty.sellerId,
          isOnline: true,
        );
      }

      final apiMsgs = result['messages'] as List<ChatApiMessageItemModel>?;
      if (apiMsgs != null && apiMsgs.isNotEmpty) {
        final List<ChatMessageModel> mapped = apiMsgs.map((m) {
          DateTime dt;
          try {
            // "28 Oct, 2026 10:48 AM"
            dt = DateFormat("dd MMM, yyyy hh:mm a").parse(m.createdAt);
          } catch (_) {
            dt = DateTime.now();
          }

          String? firstAttachment;
          if (m.attachments.isNotEmpty) {
            final att = m.attachments.first;
            if (att is String) {
              firstAttachment = att;
            } else if (att is Map && att['url'] != null) {
              firstAttachment = att['url'].toString();
            }
          }

          return ChatMessageModel(
            id: m.id.toString(),
            senderId: m.isCustomer ? currentUserId.value : activeUser.value.id,
            senderName:
                m.isCustomer ? currentUserName.value : activeUser.value.name,
            message: m.message,
            timestamp: dt,
            isMe: m.isCustomer,
            type:
                firstAttachment != null ? MessageType.image : MessageType.text,
            imageUrl: firstAttachment,
            status: m.isSeen ? MessageStatus.read : MessageStatus.delivered,
          );
        }).toList();

        messages.assignAll(mapped);
        scrollToBottom();

        // Mark as seen on API 4
        markAsRead();
      } else if (messages.isEmpty) {
        _loadDefaultWelcomeMessages();
      }
    } catch (e) {
      debugPrint("Error fetching chat messages: $e");
      if (messages.isEmpty) {
        _loadDefaultWelcomeMessages();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Background polling without disturbing user scroll
  Future<void> _pollNewMessages() async {
    try {
      final result = await _chatService.getMessages(
        domain: domain,
        type: activeUser.value.type,
        shopId: activeUser.value.shopId,
        sellerId: activeUser.value.sellerId,
      );

      final apiMsgs = result['messages'] as List<ChatApiMessageItemModel>?;
      if (apiMsgs != null && apiMsgs.isNotEmpty) {
        if (apiMsgs.length != messages.length) {
          fetchMessages(showLoader: false);
        }
      }
    } catch (_) {}
  }

  void _loadDefaultWelcomeMessages() {
    final now = DateTime.now();
    messages.assignAll([
      ChatMessageModel(
        id: 'msg_welcome_1',
        senderId: activeUser.value.id,
        senderName: activeUser.value.name,
        message:
            'Hello! 👋 How can we help you today with ${activeUser.value.name}?',
        timestamp: now,
        isMe: false,
        status: MessageStatus.read,
      ),
      if (initialOrderId != null)
        ChatMessageModel(
          id: 'msg_order_ref',
          senderId: currentUserId.value,
          senderName: currentUserName.value,
          message: 'Hi, I need assistance with my order #$initialOrderId',
          timestamp: now,
          isMe: true,
          status: MessageStatus.sent,
          orderId: initialOrderId,
          type: MessageType.orderCard,
        ),
    ]);
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 2. Send Message to API 1: POST api/v1/ecommerce/chat/send
  Future<void> sendMessage({String? textOverride}) async {
    final text = (textOverride ?? textController.text).trim();
    if (text.isEmpty) return;

    final tempId = _uuid.v4();
    final localMsg = ChatMessageModel(
      id: tempId,
      senderId: currentUserId.value,
      senderName: currentUserName.value,
      message: text,
      timestamp: DateTime.now(),
      isMe: true,
      status: MessageStatus.sending,
    );

    messages.add(localMsg);
    if (textOverride == null) {
      textController.clear();
    }
    scrollToBottom();

    // Call API 1
    final success = await _chatService.sendMessage(
      domain: domain,
      type: activeUser.value.type,
      shopId: activeUser.value.shopId,
      sellerId: activeUser.value.sellerId,
      message: text,
    );

    final index = messages.indexWhere((m) => m.id == tempId);
    if (index != -1) {
      if (success) {
        messages[index] = messages[index].copyWith(status: MessageStatus.sent);
      } else {
        messages[index] = messages[index].copyWith(status: MessageStatus.sent);
      }
    }

    // Refresh after short delay to get the server timestamp and counterparty response
    Future.delayed(const Duration(milliseconds: 1200), () {
      fetchMessages(showLoader: false);
    });
  }

  /// 3. Send image attachment
  Future<void> pickAndSendImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1200,
      );

      if (pickedFile == null) return;

      isSendingImage.value = true;
      final tempId = _uuid.v4();
      final localMsg = ChatMessageModel(
        id: tempId,
        senderId: currentUserId.value,
        senderName: currentUserName.value,
        message: '📷 Image attached',
        timestamp: DateTime.now(),
        isMe: true,
        type: MessageType.image,
        localImagePath: pickedFile.path,
        status: MessageStatus.sending,
      );

      messages.add(localMsg);
      scrollToBottom();

      final success = await _chatService.sendMessage(
        domain: domain,
        type: activeUser.value.type,
        shopId: activeUser.value.shopId,
        sellerId: activeUser.value.sellerId,
        message: 'Image attachment',
        imagePath: pickedFile.path,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1 && success) {
        messages[index] = messages[index].copyWith(status: MessageStatus.sent);
      }

      Future.delayed(const Duration(milliseconds: 1500), () {
        fetchMessages(showLoader: false);
      });
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        'Could not attach image. Please check permissions.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingImage.value = false;
    }
  }

  /// 4. Mark as read on API 4
  Future<void> markAsRead() async {
    await _chatService.markMessagesAsRead(
      domain: domain,
      shopId: activeUser.value.shopId,
      type: activeUser.value.type,
    );
  }

  void clearChat() {
    messages.clear();
    _loadDefaultWelcomeMessages();
  }
}
