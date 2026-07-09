class ClaimTransaction {
  final String id;
  final String title;
  final double amount;
  final String type; // 'escrowCredit', 'rewardRelease', 'cashOut'
  final String status; // 'pending', 'available', 'completed'
  final DateTime timestamp;
  final String itemId;

  ClaimTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
    required this.itemId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'itemId': itemId,
    };
  }

  factory ClaimTransaction.fromMap(Map<String, dynamic> map) {
    return ClaimTransaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'escrowCredit',
      status: map['status'] ?? 'pending',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      itemId: map['itemId'] ?? '',
    );
  }
}
