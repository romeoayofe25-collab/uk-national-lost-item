import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // Toggle this to false when GoogleServices configuration files are loaded
  static const bool useMock = true;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Mock Database in-memory map
  static final Map<String, AppUser> _mockUsers = {
    'owner@test.com': AppUser(
      uid: 'owner_uid',
      email: 'owner@test.com',
      displayName: 'Sarah Jenkins',
      role: 'owner',
      trustScore: 98,
      status: 'active',
    ),
    'finder@test.com': AppUser(
      uid: 'finder_uid',
      email: 'finder@test.com',
      displayName: 'Marcus Vance',
      role: 'finder',
      trustScore: 95,
      status: 'active',
    ),
    'intermediary@test.com': AppUser(
      uid: 'intermediary_uid',
      email: 'intermediary@test.com',
      displayName: 'John Miller',
      role: 'intermediary',
      trustScore: 100,
      status: 'active',
    ),
    'admin@test.com': AppUser(
      uid: 'admin_uid',
      email: 'admin@test.com',
      displayName: 'Super Admin',
      role: 'admin',
      trustScore: 100,
      status: 'active',
    ),
    'suspended@test.com': AppUser(
      uid: 'suspended_uid',
      email: 'suspended@test.com',
      displayName: 'Rogue User',
      role: 'owner',
      trustScore: 45,
      status: 'suspended',
    ),
  };

  // Sign In
  Future<AppUser?> signIn(String email, String password) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency
      final user = _mockUsers[email.trim().toLowerCase()];
      if (user != null) {
        return user;
      }
      throw Exception('User not found in Mock database. Try owner@test.com, finder@test.com, or suspended@test.com.');
    } else {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        final doc = await _db.collection('users').doc(credential.user!.uid).get();
        if (doc.exists && doc.data() != null) {
          return AppUser.fromMap(doc.data()!, credential.user!.uid);
        }
      }
      return null;
    }
  }

  // Sign Up
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (_mockUsers.containsKey(cleanEmail)) {
        throw Exception('Account already exists in Mock database.');
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
    } else {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final newUser = AppUser(
        uid: credential.user!.uid,
        email: cleanEmail,
        displayName: displayName,
        role: role,
        trustScore: 100,
        status: 'active',
      );
      
      await _db.collection('users').doc(credential.user!.uid).set(newUser.toMap());
      return newUser;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    if (!useMock) {
      await _auth.signOut();
    }
  }
}
