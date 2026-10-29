class SupportTicketMetadataModel {
  final String domain;
  final String domainName;
  final int shopId;
  final String vendor;
  final List<String> types;
  final Map<String, String> priorities;

  SupportTicketMetadataModel({
    required this.domain,
    required this.domainName,
    required this.shopId,
    required this.vendor,
    required this.types,
    required this.priorities,
  });

  factory SupportTicketMetadataModel.fromJson(Map<String, dynamic> json) {
    final List<String> typesList = [];
    if (json['types'] is List) {
      for (final t in json['types']) {
        if (t != null) typesList.add(t.toString());
      }
    }

    final Map<String, String> prioritiesMap = {};
    if (json['priorities'] is Map) {
      json['priorities'].forEach((k, v) {
        if (k != null && v != null) {
          prioritiesMap[k.toString()] = v.toString();
        }
      });
    }

    return SupportTicketMetadataModel(
      domain: json['domain']?.toString() ?? 'e-team-12',
      domainName: json['domain_name']?.toString() ?? 'e-team-12',
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? '1') ?? 1,
      vendor: json['vendor']?.toString() ?? '',
      types: typesList,
      priorities: prioritiesMap,
    );
  }
}

class SupportTicketModel {
  final int id;
  final String ticketNumber;
  final String subject;
  final String type;
  final String priority;
  final String priorityLabel;
  final String status;
  final String statusLabel;
  final String description;
  final List<String> attachments;
  final int messagesCount;
  final String createdAt;
  final String timeAgo;
  final String lastUpdated;

  SupportTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.type,
    required this.priority,
    required this.priorityLabel,
    required this.status,
    required this.statusLabel,
    required this.description,
    this.attachments = const [],
    this.messagesCount = 0,
    required this.createdAt,
    this.timeAgo = '',
    this.lastUpdated = '',
  });

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isClosed => status.toLowerCase() == 'closed';
  bool get isResolved => status.toLowerCase() == 'resolved';

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final List<String> attachmentsList = [];
    if (json['attachments'] is List) {
      for (final a in json['attachments']) {
        if (a != null) attachmentsList.add(a.toString());
      }
    }

    return SupportTicketModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? json['ticket_id']?.toString() ?? '0') ?? 0,
      ticketNumber: json['ticket_number']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      priorityLabel: json['priority_label']?.toString() ??
          (json['priority']?.toString().capitalizeFirst ?? 'Medium'),
      status: json['status']?.toString() ?? 'open',
      statusLabel: json['status_label']?.toString() ??
          (json['status']?.toString().capitalizeFirst ?? 'Open'),
      description: json['description']?.toString() ?? '',
      attachments: attachmentsList,
      messagesCount: json['messages_count'] is int
          ? json['messages_count']
          : int.tryParse(json['messages_count']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
      lastUpdated: json['last_updated']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'subject': subject,
      'type': type,
      'priority': priority,
      'priority_label': priorityLabel,
      'status': status,
      'status_label': statusLabel,
      'description': description,
      'attachments': attachments,
      'messages_count': messagesCount,
      'created_at': createdAt,
      'time_ago': timeAgo,
      'last_updated': lastUpdated,
    };
  }
}

class TicketConversationModel {
  final int id;
  final String sender;
  final String senderName;
  final String message;
  final List<String> attachments;
  final String createdAt;
  final String timeAgo;

  TicketConversationModel({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.message,
    this.attachments = const [],
    required this.createdAt,
    this.timeAgo = '',
  });

  bool get isCustomer =>
      sender.toLowerCase() == 'customer' || senderName.toLowerCase() == 'you';

  factory TicketConversationModel.fromJson(Map<String, dynamic> json) {
    final List<String> attachmentsList = [];
    if (json['attachments'] is List) {
      for (final a in json['attachments']) {
        if (a != null) attachmentsList.add(a.toString());
      }
    }

    return TicketConversationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? json['reply_id']?.toString() ?? '0') ?? 0,
      sender: json['sender']?.toString() ?? 'customer',
      senderName: json['sender_name']?.toString() ?? 'You',
      message: json['message']?.toString() ?? '',
      attachments: attachmentsList,
      createdAt: json['created_at']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
    );
  }
}

class SupportTicketDetailsModel {
  final SupportTicketModel ticket;
  final List<TicketConversationModel> conversations;

  SupportTicketDetailsModel({
    required this.ticket,
    this.conversations = const [],
  });

  factory SupportTicketDetailsModel.fromJson(Map<String, dynamic> json) {
    final ticketMap = json['ticket_details'] is Map<String, dynamic>
        ? json['ticket_details'] as Map<String, dynamic>
        : json;

    final ticket = SupportTicketModel.fromJson(ticketMap);

    final List<TicketConversationModel> conversationsList = [];
    if (ticketMap['conversations'] is List) {
      for (final c in ticketMap['conversations']) {
        if (c is Map<String, dynamic>) {
          conversationsList.add(TicketConversationModel.fromJson(c));
        }
      }
    }

    return SupportTicketDetailsModel(
      ticket: ticket,
      conversations: conversationsList,
    );
  }
}

extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

