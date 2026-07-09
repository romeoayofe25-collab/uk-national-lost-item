class VerificationQuestion {
  final String id;
  final String questionText;

  VerificationQuestion({
    required this.id,
    required this.questionText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
    };
  }

  factory VerificationQuestion.fromMap(Map<String, dynamic> map) {
    return VerificationQuestion(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'owner', 'finder', 'admin', 'intermediary', 'system'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class LostItem {
  final String id;
  final String title;
  final String category;
  final String? brand;
  final String? colour;
  final String? uniqueMarks;
  final double estimatedValue;
  final DateTime dateLost;
  final String timeLost;
  final String lastKnownLocation;
  final double? latitude;
  final double? longitude;
  final List<String> photos;
  final List<String> proofDocuments;
  final String? serialNumber;
  final String status; // 'searching', 'matchFound', 'underReview', 'readyForCollection', 'returned'
  final String? secureCollectionPin;
  final List<VerificationQuestion> verificationQuestions;
  final Map<String, String> verificationAnswers;
  final String? verificationSerialNumber;
  final List<ChatMessage> messages;
  final String? storageLocation;

  LostItem({
    required this.id,
    required this.title,
    required this.category,
    this.brand,
    this.colour,
    this.uniqueMarks,
    required this.estimatedValue,
    required this.dateLost,
    required this.timeLost,
    required this.lastKnownLocation,
    this.latitude,
    this.longitude,
    this.photos = const [],
    this.proofDocuments = const [],
    this.serialNumber,
    required this.status,
    this.secureCollectionPin,
    this.verificationQuestions = const [],
    this.verificationAnswers = const {},
    this.verificationSerialNumber,
    this.messages = const [],
    this.storageLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'brand': brand,
      'colour': colour,
      'uniqueMarks': uniqueMarks,
      'estimatedValue': estimatedValue,
      'dateLost': dateLost.toIso8601String(),
      'timeLost': timeLost,
      'lastKnownLocation': lastKnownLocation,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'proofDocuments': proofDocuments,
      'serialNumber': serialNumber,
      'status': status,
      'secureCollectionPin': secureCollectionPin,
      'verificationQuestions': verificationQuestions.map((q) => q.toMap()).toList(),
      'verificationAnswers': verificationAnswers,
      'verificationSerialNumber': verificationSerialNumber,
      'messages': messages.map((m) => m.toMap()).toList(),
      'storageLocation': storageLocation,
    };
  }

  factory LostItem.fromMap(Map<String, dynamic> map, String docId) {
    return LostItem(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'],
      colour: map['colour'],
      uniqueMarks: map['uniqueMarks'],
      estimatedValue: (map['estimatedValue'] ?? 0.0).toDouble(),
      dateLost: DateTime.parse(map['dateLost'] ?? DateTime.now().toIso8601String()),
      timeLost: map['timeLost'] ?? '',
      lastKnownLocation: map['lastKnownLocation'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      photos: List<String>.from(map['photos'] ?? []),
      proofDocuments: List<String>.from(map['proofDocuments'] ?? []),
      serialNumber: map['serialNumber'],
      status: map['status'] ?? 'searching',
      secureCollectionPin: map['secureCollectionPin'],
      verificationQuestions: (map['verificationQuestions'] as List?)
              ?.map((q) => VerificationQuestion.fromMap(q))
              .toList() ??
          [],
      verificationAnswers: Map<String, String>.from(map['verificationAnswers'] ?? {}),
      verificationSerialNumber: map['verificationSerialNumber'],
      messages: (map['messages'] as List?)
              ?.map((m) => ChatMessage.fromMap(m))
              .toList() ??
          [],
      storageLocation: map['storageLocation'],
    );
  }

  LostItem copyWith({
    String? title,
    String? category,
    String? brand,
    String? colour,
    String? uniqueMarks,
    double? estimatedValue,
    DateTime? dateLost,
    String? timeLost,
    String? lastKnownLocation,
    double? latitude,
    double? longitude,
    List<String>? photos,
    List<String>? proofDocuments,
    String? serialNumber,
    String? status,
    String? secureCollectionPin,
    List<VerificationQuestion>? verificationQuestions,
    Map<String, String>? verificationAnswers,
    String? verificationSerialNumber,
    List<ChatMessage>? messages,
    String? storageLocation,
  }) {
    return LostItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      colour: colour ?? this.colour,
      uniqueMarks: uniqueMarks ?? this.uniqueMarks,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      dateLost: dateLost ?? this.dateLost,
      timeLost: timeLost ?? this.timeLost,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: photos ?? this.photos,
      proofDocuments: proofDocuments ?? this.proofDocuments,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      secureCollectionPin: secureCollectionPin ?? this.secureCollectionPin,
      verificationQuestions: verificationQuestions ?? this.verificationQuestions,
      verificationAnswers: verificationAnswers ?? this.verificationAnswers,
      verificationSerialNumber: verificationSerialNumber ?? this.verificationSerialNumber,
      messages: messages ?? this.messages,
      storageLocation: storageLocation ?? this.storageLocation,
    );
  }
}
