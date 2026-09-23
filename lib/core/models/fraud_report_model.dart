class FraudReport {
  final String id;
  final String reportedItemId;
  final String reportedItemTitle;
  final String? reportedUserId;
  final String? reportedUserName;
  final String reporterId;
  final String reporterRole; // 'owner', 'finder', 'intermediary'
  final String category; // 'stolenGoods', 'extortionBidding', 'fakeProof', 'falseClaim', 'unsafeMeeting', 'harassment'
  final String description;
  final String? evidenceNotes;
  final String status; // 'pendingReview', 'investigating', 'frozen', 'resolved', 'dismissed'
  final String? actionTaken;
  final String severity; // 'high', 'medium', 'low'
  final DateTime timestamp;

  FraudReport({
    required this.id,
    required this.reportedItemId,
    required this.reportedItemTitle,
    this.reportedUserId,
    this.reportedUserName,
    required this.reporterId,
    required this.reporterRole,
    required this.category,
    required this.description,
    this.evidenceNotes,
    this.status = 'pendingReview',
    this.actionTaken,
    this.severity = 'medium',
    required this.timestamp,
  });

  String get categoryLabel {
    switch (category) {
      case 'stolenGoods':
        return 'Suspected Stolen Property';
      case 'extortionBidding':
        return 'Reward Extortion / Off-Platform Demand';
      case 'fakeProof':
        return 'Fake Serial Number / Tampered Proof';
      case 'falseClaim':
        return 'Fraudulent Claim / Impersonating Owner';
      case 'unsafeMeeting':
        return 'Attempted Direct Meetup / Rule 10 Violation';
      case 'harassment':
        return 'Abuse or Threatening Conduct';
      default:
        return 'Suspicious Activity';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportedItemId': reportedItemId,
      'reportedItemTitle': reportedItemTitle,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'reporterId': reporterId,
      'reporterRole': reporterRole,
      'category': category,
      'description': description,
      'evidenceNotes': evidenceNotes,
      'status': status,
      'actionTaken': actionTaken,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FraudReport.fromMap(Map<String, dynamic> map, String docId) {
    return FraudReport(
      id: docId,
      reportedItemId: map['reportedItemId'] ?? '',
      reportedItemTitle: map['reportedItemTitle'] ?? '',
      reportedUserId: map['reportedUserId'],
      reportedUserName: map['reportedUserName'],
      reporterId: map['reporterId'] ?? '',
      reporterRole: map['reporterRole'] ?? 'owner',
      category: map['category'] ?? 'suspiciousActivity',
      description: map['description'] ?? '',
      evidenceNotes: map['evidenceNotes'],
      status: map['status'] ?? 'pendingReview',
      actionTaken: map['actionTaken'],
      severity: map['severity'] ?? 'medium',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  FraudReport copyWith({
    String? status,
    String? actionTaken,
    String? severity,
    String? evidenceNotes,
  }) {
    return FraudReport(
      id: id,
      reportedItemId: reportedItemId,
      reportedItemTitle: reportedItemTitle,
      reportedUserId: reportedUserId,
      reportedUserName: reportedUserName,
      reporterId: reporterId,
      reporterRole: reporterRole,
      category: category,
      description: description,
      evidenceNotes: evidenceNotes ?? this.evidenceNotes,
      status: status ?? this.status,
      actionTaken: actionTaken ?? this.actionTaken,
      severity: severity ?? this.severity,
      timestamp: timestamp,
    );
  }
}
