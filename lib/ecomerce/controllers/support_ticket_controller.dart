import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/support_ticket_model.dart';
import '../services/support_ticket_service.dart';

class SupportTicketController extends GetxController implements GetxService {
  static SupportTicketController get instance {
    if (Get.isRegistered<SupportTicketController>()) {
      return Get.find<SupportTicketController>();
    }
    return Get.put(SupportTicketController());
  }

  final SupportTicketService _service = SupportTicketService();
  final String domain = 'e-team-12';

  // 1. Ticket List State
  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;
  final RxBool isLoadingTickets = false.obs;
  final RxString ticketsError = ''.obs;
  final RxString selectedStatus = 'all'.obs; // 'all', 'open', 'resolved', 'closed'
  final RxString searchQuery = ''.obs;

  // 2. Metadata / Types State
  final Rxn<SupportTicketMetadataModel> metadata = Rxn<SupportTicketMetadataModel>();
  final RxBool isLoadingMetadata = false.obs;

  // 3. Ticket Creation State
  final RxBool isCreatingTicket = false.obs;

  // 4. Ticket Details State
  final Rxn<SupportTicketDetailsModel> currentTicketDetails =
      Rxn<SupportTicketDetailsModel>();
  final RxBool isLoadingDetails = false.obs;
  final RxString detailsError = ''.obs;

  // 5. Reply State
  final RxBool isSendingReply = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
    fetchMetadata();
  }

  /// Get filtered tickets by status & search query
  List<SupportTicketModel> get filteredTickets {
    var list = tickets.toList();

    // Status filter
    if (selectedStatus.value != 'all') {
      list = list.where((t) {
        return t.status.toLowerCase() == selectedStatus.value.toLowerCase();
      }).toList();
    }

    // Search query filter
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      list = list.where((t) {
        final matchesNum = t.ticketNumber.toLowerCase().contains(q);
        final matchesSub = t.subject.toLowerCase().contains(q);
        final matchesType = t.type.toLowerCase().contains(q);
        return matchesNum || matchesSub || matchesType;
      }).toList();
    }

    return list;
  }

  int get openTicketsCount =>
      tickets.where((t) => t.status.toLowerCase() == 'open').length;

  int get resolvedTicketsCount =>
      tickets.where((t) => t.status.toLowerCase() == 'resolved').length;

  int get closedTicketsCount =>
      tickets.where((t) => t.status.toLowerCase() == 'closed').length;

  /// Fetch all support tickets
  Future<void> fetchTickets() async {
    try {
      isLoadingTickets.value = true;
      ticketsError.value = '';
      final list = await _service.getTickets(domain: domain);
      tickets.assignAll(list);
    } catch (e) {
      ticketsError.value = e.toString();
    } finally {
      isLoadingTickets.value = false;
    }
  }

  /// Fetch support ticket types and priorities metadata
  Future<void> fetchMetadata() async {
    try {
      isLoadingMetadata.value = true;
      final data = await _service.getTicketTypes(domain: domain);
      if (data != null) {
        metadata.value = data;
      }
    } catch (e) {
      debugPrint("SupportTicketController fetchMetadata error: $e");
    } finally {
      isLoadingMetadata.value = false;
    }
  }

  /// Create a new support ticket
  Future<bool> createTicket({
    required String subject,
    required String type,
    required String priority,
    required String description,
    int? orderId,
  }) async {
    try {
      isCreatingTicket.value = true;
      final result = await _service.createTicket(
        domain: domain,
        subject: subject,
        type: type,
        priority: priority,
        description: description,
        orderId: orderId,
      );

      if (result['success'] == true) {
        // Refresh ticket list
        await fetchTickets();
        Get.snackbar(
          "Success",
          result['message'] ?? "Support ticket created successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00C853),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        Get.snackbar(
          "Error",
          result['message'] ?? "Could not create support ticket",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isCreatingTicket.value = false;
    }
  }

  /// Fetch ticket details & conversations
  Future<void> fetchTicketDetails(int ticketId) async {
    try {
      isLoadingDetails.value = true;
      detailsError.value = '';
      final details = await _service.getTicketDetails(
        ticketId: ticketId,
        domain: domain,
      );
      if (details != null) {
        currentTicketDetails.value = details;
      } else {
        detailsError.value = "Failed to load ticket details";
      }
    } catch (e) {
      detailsError.value = e.toString();
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Send a reply to the ticket
  Future<bool> sendReply({
    required int ticketId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return false;

    try {
      isSendingReply.value = true;
      final result = await _service.replyTicket(
        ticketId: ticketId,
        message: message.trim(),
        domain: domain,
      );

      if (result['success'] == true) {
        final newReply = result['data'] as TicketConversationModel?;
        if (newReply != null && currentTicketDetails.value != null) {
          final updatedConversations = List<TicketConversationModel>.from(
            currentTicketDetails.value!.conversations,
          )..add(newReply);

          currentTicketDetails.value = SupportTicketDetailsModel(
            ticket: currentTicketDetails.value!.ticket,
            conversations: updatedConversations,
          );
        } else {
          // Re-fetch details
          await fetchTicketDetails(ticketId);
        }

        // Update list in background
        fetchTickets();
        return true;
      } else {
        Get.snackbar(
          "Failed to send reply",
          result['message'] ?? "Please try again later",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isSendingReply.value = false;
    }
  }
}

