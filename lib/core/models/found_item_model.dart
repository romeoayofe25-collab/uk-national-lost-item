import 'lost_item_model.dart'; // To reuse ChatMessage

class FoundItem {
  final String id;
  final String title;
  final String category;
  final String? brand;
  final String? colour;
  final String publicDescription;
  final String? privateDetails; // Hides unique details from public view (Rule 5)
  final DateTime dateFound;
  final String timeFound;
  final String locationFound;
  final double? latitude;
  final double? longitude;
  final List<String> photos;
  final String status; // 'heldByFinder', 'deposited', 'matched', 'returned'
  final String? secureDepositPin; // Single-use deposit voucher code
  final String? dropOffCentreName;
  final DateTime? dropOffTimestamp;
  final double rewardAmount;
  final List<ChatMessage> messages;
  final String? storageLocation;

  FoundItem({
    required this.id,
    required this.title,
    required this.category,
    this.brand,
    this.colour,
    required this.publicDescription,
    this.privateDetails,
    required this.dateFound,
    required this.timeFound,
    required this.locationFound,
    this.latitude,
    this.longitude,
    this.photos = const [],
    required this.status,
    this.secureDepositPin,
    this.dropOffCentreName,
    this.dropOffTimestamp,
    this.rewardAmount = 0.0,
    this.messages = const [],
    this.storageLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'brand': brand,
      'colour': colour,
      'publicDescription': publicDescription,
      'privateDetails': privateDetails,
      'dateFound': dateFound.toIso8601String(),
      'timeFound': timeFound,
      'locationFound': locationFound,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'status': status,
      'secureDepositPin': secureDepositPin,
      'dropOffCentreName': dropOffCentreName,
      'dropOffTimestamp': dropOffTimestamp?.toIso8601String(),
      'rewardAmount': rewardAmount,
      'messages': messages.map((m) => m.toMap()).toList(),
      'storageLocation': storageLocation,
    };
  }

  factory FoundItem.fromMap(Map<String, dynamic> map, String docId) {
    return FoundItem(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'],
      colour: map['colour'],
      publicDescription: map['publicDescription'] ?? '',
      privateDetails: map['privateDetails'],
      dateFound: DateTime.parse(map['dateFound'] ?? DateTime.now().toIso8601String()),
      timeFound: map['timeFound'] ?? '',
      locationFound: map['locationFound'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      photos: List<String>.from(map['photos'] ?? []),
      status: map['status'] ?? 'heldByFinder',
      secureDepositPin: map['secureDepositPin'],
      dropOffCentreName: map['dropOffCentreName'],
      dropOffTimestamp: map['dropOffTimestamp'] != null
          ? DateTime.parse(map['dropOffTimestamp'])
          : null,
      rewardAmount: (map['rewardAmount'] ?? 0.0).toDouble(),
      messages: (map['messages'] as List?)
              ?.map((m) => ChatMessage.fromMap(m))
              .toList() ??
          [],
      storageLocation: map['storageLocation'],
    );
  }

  FoundItem copyWith({
    String? title,
    String? category,
    String? brand,
    String? colour,
    String? publicDescription,
    String? privateDetails,
    DateTime? dateFound,
    String? timeFound,
    String? locationFound,
    double? latitude,
    double? longitude,
    List<String>? photos,
    String? status,
    String? secureDepositPin,
    String? dropOffCentreName,
    DateTime? dropOffTimestamp,
    double? rewardAmount,
    List<ChatMessage>? messages,
    String? storageLocation,
  }) {
    return FoundItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      colour: colour ?? this.colour,
      publicDescription: publicDescription ?? this.publicDescription,
      privateDetails: privateDetails ?? this.privateDetails,
      dateFound: dateFound ?? this.dateFound,
      timeFound: timeFound ?? this.timeFound,
      locationFound: locationFound ?? this.locationFound,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      secureDepositPin: secureDepositPin ?? this.secureDepositPin,
      dropOffCentreName: dropOffCentreName ?? this.dropOffCentreName,
      dropOffTimestamp: dropOffTimestamp ?? this.dropOffTimestamp,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      messages: messages ?? this.messages,
      storageLocation: storageLocation ?? this.storageLocation,
    );
  }
}
