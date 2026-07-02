class AdminConversationSummary {
  AdminConversationSummary({
    required this.conversationId,
    required this.customerUserId,
    required this.customerName,
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageSentAt,
    required this.unreadCount,
    required this.createdAt,
    this.updatedAt,
  });

  final int conversationId;
  final int customerUserId;
  final String customerName;
  final String? lastMessage;
  final String? lastMessageSender;
  final DateTime? lastMessageSentAt;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory AdminConversationSummary.fromJson(Map<String, dynamic> json) =>
      AdminConversationSummary(
        conversationId: json['conversationId'],
        customerUserId: json['customerUserId'],
        customerName: json['customerName'] ?? 'Khách hàng',
        lastMessage: json['lastMessage'],
        lastMessageSender: json['lastMessageSender'],
        lastMessageSentAt: json['lastMessageSentAt'] == null
            ? null
            : DateTime.parse(json['lastMessageSentAt']),
        unreadCount: json['unreadCount'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt']),
      );
}
