import '../models/user_model.dart';

/// In-memory demo accounts for the prototype.
///
/// There is no real sign-in: the five built-in accounts accept any password,
/// and new registrations last only until the app restarts. This class is the
/// seam where a real authentication service would connect.
class AuthService {
  // Demo accounts, keyed by email
  static final Map<String, AppUser> _mockUsers = {
    'owner@test.com': AppUser(
      uid: 'owner_uid',
      email: 'owner@test.com',
      displayName: 'Sarah Jenkins',
      role: 'owner',
      trustScore: 98,
      status: 'active',
      verificationTier: 'tier3_biometric',
      phoneNumberMasked: '+44 7911 ***892',
      biometricConsentGiven: true,
      biometricHash: 'sha256_mock_hash_test_token_8899',
      idDocumentType: 'UK Passport',
      idDocumentMasked: 'GBR-PAS-***-1948',
      biometricRegisteredAt: DateTime(2026, 8, 1, 14, 20),
      dataRetentionConsentDate: DateTime(2026, 8, 1, 14, 20),
    ),
    'finder@test.com': AppUser(
      uid: 'finder_uid',
      email: 'finder@test.com',
      displayName: 'Marcus Vance',
      role: 'finder',
      trustScore: 95,
      status: 'active',
      verificationTier: 'tier2_contact',
      phoneNumberMasked: '+44 7700 ***123',
      biometricConsentGiven: false,
      dataRetentionConsentDate: DateTime(2026, 8, 10, 11, 0),
    ),
    'intermediary@test.com': AppUser(
      uid: 'intermediary_uid',
      email: 'intermediary@test.com',
      displayName: 'John Miller',
      role: 'intermediary',
      trustScore: 100,
      status: 'active',
      verificationTier: 'tier3_biometric',
      phoneNumberMasked: '+44 20 7946 ***4',
      idDocumentType: 'Station Officer ID',
      idDocumentMasked: 'UK-INT-***-901',
      biometricConsentGiven: true,
      biometricHash: 'sha256_mock_hash_intermediary_772',
      biometricRegisteredAt: DateTime(2026, 7, 15, 9, 30),
      dataRetentionConsentDate: DateTime(2026, 7, 15, 9, 30),
    ),
    'admin@test.com': AppUser(
      uid: 'admin_uid',
      email: 'admin@test.com',
      displayName: 'Super Admin',
      role: 'admin',
      trustScore: 100,
      status: 'active',
      verificationTier: 'tier3_biometric',
      phoneNumberMasked: '+44 800 *** 0199',
      idDocumentType: 'Admin Board Credential',
      idDocumentMasked: 'UK-ADM-***-001',
      biometricConsentGiven: true,
      biometricHash: 'sha256_mock_hash_admin_001',
      biometricRegisteredAt: DateTime(2026, 6, 1, 8, 0),
      dataRetentionConsentDate: DateTime(2026, 6, 1, 8, 0),
    ),
    'suspended@test.com': AppUser(
      uid: 'suspended_uid',
      email: 'suspended@test.com',
      displayName: 'Rogue User',
      role: 'owner',
      trustScore: 45,
      status: 'suspended',
      verificationTier: 'tier1_basic',
      phoneNumberMasked: '+44 7000 ***999',
      biometricConsentGiven: false,
    ),
  };

  // Sign In
  Future<AppUser?> signIn(String email, String password) async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulate network latency
    final user = _mockUsers[email.trim().toLowerCase()];
    if (user != null) {
      return user;
    }
    throw Exception(
      'No demo account with that email. Use a role button, or owner@, finder@, intermediary@, admin@ or suspended@test.com.',
    );
  }

  // Sign Up
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    await Future.delayed(const Duration(milliseconds: 800));
    if (_mockUsers.containsKey(cleanEmail)) {
      throw Exception(
        'An account with that email already exists in this demo.',
      );
    }

    final newUser = AppUser(
      uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      displayName: displayName,
      role: role,
      trustScore: 100,
      status: 'active',
    );

    _mockUsers[cleanEmail] = newUser;
    return newUser;
  }

  // Sign Out: nothing to clear, because the demo keeps no session outside memory.
  Future<void> signOut() async {}

  static List<AppUser> get mockUsersList => _mockUsers.values.toList();

  static void suspendUser(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (_mockUsers.containsKey(cleanEmail)) {
      final u = _mockUsers[cleanEmail]!;
      _mockUsers[cleanEmail] = u.copyWith(status: 'suspended');
    }
  }

  static void activateUser(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (_mockUsers.containsKey(cleanEmail)) {
      final u = _mockUsers[cleanEmail]!;
      _mockUsers[cleanEmail] = u.copyWith(status: 'active');
    }
  }

  static void purgeBiometricData(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (_mockUsers.containsKey(cleanEmail)) {
      final u = _mockUsers[cleanEmail]!;
      _mockUsers[cleanEmail] = u.copyWith(
        verificationTier: 'tier2_contact',
        clearBiometrics: true,
      );
    }
  }

  static void updateBiometricConsent(String email, bool consent) {
    final cleanEmail = email.trim().toLowerCase();
    if (_mockUsers.containsKey(cleanEmail)) {
      final u = _mockUsers[cleanEmail]!;
      _mockUsers[cleanEmail] = u.copyWith(biometricConsentGiven: consent);
    }
  }
}
