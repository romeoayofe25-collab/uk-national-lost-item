class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'rewardAssessed', 'matchFound', 'biometricVerified', 'custodyDeposited', 'voucherReady', 'escrowReleased', 'securityAlert', 'adminMessage'
  final String category; // 'claims', 'custody', 'rewards', 'security'
  final String? relatedItemId;
  final String? relatedItemTitle;
  final String recipientRole; // 'all', 'owner', 'finder', 'intermediary', 'admin'
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    this.relatedItemId,
    this.relatedItemTitle,
    this.recipientRole = 'all',
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'category': category,
      'relatedItemId': relatedItemId,
      'relatedItemTitle': relatedItemTitle,
      'recipientRole': recipientRole,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'actionRoute': actionRoute,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, String docId) {
    return AppNotification(
      id: docId,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'adminMessage',
      category: map['category'] ?? 'claims',
      relatedItemId: map['relatedItemId'],
      relatedItemTitle: map['relatedItemTitle'],
      recipientRole: map['recipientRole'] ?? 'all',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
      actionRoute: map['actionRoute'],
    );
  }

  AppNotification copyWith({
    bool? isRead,
    String? title,
    String? message,
    String? actionRoute,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type,
      category: category,
      relatedItemId: relatedItemId,
      relatedItemTitle: relatedItemTitle,
      recipientRole: recipientRole,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}
