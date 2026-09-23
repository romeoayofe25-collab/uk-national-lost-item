class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'owner', 'finder', 'intermediary', 'admin'
  final int trustScore;
  final String status; // 'active', 'suspended'
  final String verificationTier; // 'tier1_basic', 'tier2_contact', 'tier3_biometric'
  final String? phoneNumberMasked;
  final bool biometricConsentGiven;
  final String? biometricHash;
  final String? idDocumentType;
  final String? idDocumentMasked;
  final DateTime? biometricRegisteredAt;
  final DateTime? dataRetentionConsentDate;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.trustScore = 100,
    this.status = 'active',
    this.verificationTier = 'tier1_basic',
    this.phoneNumberMasked,
    this.biometricConsentGiven = false,
    this.biometricHash,
    this.idDocumentType,
    this.idDocumentMasked,
    this.biometricRegisteredAt,
    this.dataRetentionConsentDate,
  });

  bool get isSuspended => status == 'suspended';
  bool get isBiometricVerified => verificationTier == 'tier3_biometric' && biometricHash != null;

  String get tierLabel {
    switch (verificationTier) {
      case 'tier3_biometric':
        return 'Tier 3: Biometric & ID Verified';
      case 'tier2_contact':
        return 'Tier 2: Contact Verified';
      case 'tier1_basic':
      default:
        return 'Tier 1: Basic Account';
    }
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'owner',
      trustScore: map['trustScore'] ?? 100,
      status: map['status'] ?? 'active',
      verificationTier: map['verificationTier'] ?? 'tier1_basic',
      phoneNumberMasked: map['phoneNumberMasked'],
      biometricConsentGiven: map['biometricConsentGiven'] ?? false,
      biometricHash: map['biometricHash'],
      idDocumentType: map['idDocumentType'],
      idDocumentMasked: map['idDocumentMasked'],
      biometricRegisteredAt: map['biometricRegisteredAt'] != null
          ? DateTime.tryParse(map['biometricRegisteredAt'])
          : null,
      dataRetentionConsentDate: map['dataRetentionConsentDate'] != null
          ? DateTime.tryParse(map['dataRetentionConsentDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'trustScore': trustScore,
      'status': status,
      'verificationTier': verificationTier,
      'phoneNumberMasked': phoneNumberMasked,
      'biometricConsentGiven': biometricConsentGiven,
      'biometricHash': biometricHash,
      'idDocumentType': idDocumentType,
      'idDocumentMasked': idDocumentMasked,
      'biometricRegisteredAt': biometricRegisteredAt?.toIso8601String(),
      'dataRetentionConsentDate': dataRetentionConsentDate?.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    int? trustScore,
    String? status,
    String? verificationTier,
    String? phoneNumberMasked,
    bool? biometricConsentGiven,
    String? biometricHash,
    String? idDocumentType,
    String? idDocumentMasked,
    DateTime? biometricRegisteredAt,
    DateTime? dataRetentionConsentDate,
    bool clearBiometrics = false,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      trustScore: trustScore ?? this.trustScore,
      status: status ?? this.status,
      verificationTier: verificationTier ?? this.verificationTier,
      phoneNumberMasked: phoneNumberMasked ?? this.phoneNumberMasked,
      biometricConsentGiven: clearBiometrics ? false : (biometricConsentGiven ?? this.biometricConsentGiven),
      biometricHash: clearBiometrics ? null : (biometricHash ?? this.biometricHash),
      idDocumentType: clearBiometrics ? null : (idDocumentType ?? this.idDocumentType),
      idDocumentMasked: clearBiometrics ? null : (idDocumentMasked ?? this.idDocumentMasked),
      biometricRegisteredAt: clearBiometrics ? null : (biometricRegisteredAt ?? this.biometricRegisteredAt),
      dataRetentionConsentDate: dataRetentionConsentDate ?? this.dataRetentionConsentDate,
    );
  }
}
