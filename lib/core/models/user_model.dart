class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'owner', 'finder', 'intermediary', 'admin'
  final int trustScore;
  final String status; // 'active', 'suspended'

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.trustScore = 100,
    this.status = 'active',
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'owner',
      trustScore: map['trustScore'] ?? 100,
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'trustScore': trustScore,
      'status': status,
    };
  }

  bool get isSuspended => status == 'suspended';
}
