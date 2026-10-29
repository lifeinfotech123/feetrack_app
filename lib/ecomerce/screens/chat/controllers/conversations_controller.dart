import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/ecomerce/models/chat_model.dart';
import '../../../services/chat_service.dart';

class ConversationsController extends GetxController {
  final ChatService _chatService = ChatService();

  final RxList<ChatConversationItemModel> conversations =
      <ChatConversationItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<ChatUnreadCountModel> unreadCount = ChatUnreadCountModel().obs;
  final RxString searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  List<ChatConversationItemModel> get filteredConversations {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return conversations.where((c) {
      final nameMatches = c.name.toLowerCase().contains(query);
      final labelMatches = c.typeLabel.toLowerCase().contains(query);
      final msgMatches =
          c.lastMessage?.message.toLowerCase().contains(query) ?? false;
      return nameMatches || labelMatches || msgMatches;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchConversations({String? domain}) async {
    isLoading.value = true;
    try {
      final items = await _chatService.getConversations(domain: domain);
      conversations.assignAll(items);
      final counts = await _chatService.getUnreadCount(domain: domain);
      unreadCount.value = counts;
    } catch (e) {
      debugPrint("Error loading conversations: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String query) {
    searchQuery.value = query;
  }
}
