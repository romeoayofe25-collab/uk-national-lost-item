import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'items_service.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  suspended,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AppUser? _currentUser;
  AuthStatus _status = AuthStatus.unauthenticated;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isSuspended => _status == AuthStatus.suspended;

  // Clear errors
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign In
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        _currentUser = user;
        if (user.isSuspended) {
          _status = AuthStatus.suspended;
        } else {
          _status = AuthStatus.authenticated;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // GDPR Article 17 Right to Erasure - Purge Biometric Tokens
  Future<bool> purgeBiometricData(ItemsService itemsService) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      AuthService.purgeBiometricData(_currentUser!.email);
      _currentUser = _currentUser!.copyWith(
        verificationTier: 'tier2_contact',
        clearBiometrics: true,
      );
      await itemsService.purgeUserBiometrics(_currentUser!.email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Biometric Consent
  Future<bool> updateBiometricConsent(bool consent) async {
    if (_currentUser == null) return false;

    try {
      AuthService.updateBiometricConsent(_currentUser!.email, consent);
      _currentUser = _currentUser!.copyWith(
        biometricConsentGiven: consent,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // GDPR Article 15 - Right of Access (Subject Access Request - SAR)
  Map<String, dynamic> generateGDPRSubjectAccessReport(ItemsService itemsService) {
    return {
      'exportTimestamp': DateTime.now().toIso8601String(),
      'dataController': 'UK National Lost-Item Administration Board',
      'legalBasis': 'UK GDPR Article 6(1)(b) Contractual Necessity & Article 9(2)(a) Explicit Consent',
      'userProfile': {
        'uid': _currentUser?.uid,
        'email': _currentUser?.email,
        'displayName': _currentUser?.displayName,
        'role': _currentUser?.role,
        'trustScore': _currentUser?.trustScore,
        'verificationTier': _currentUser?.verificationTier,
        'phoneNumberMasked': _currentUser?.phoneNumberMasked,
        'biometricConsentGiven': _currentUser?.biometricConsentGiven,
        'isBiometricVerified': _currentUser?.isBiometricVerified,
        'idDocumentType': _currentUser?.idDocumentType,
        'idDocumentMasked': _currentUser?.idDocumentMasked,
        'biometricRegisteredAt': _currentUser?.biometricRegisteredAt?.toIso8601String(),
        'dataRetentionConsentDate': _currentUser?.dataRetentionConsentDate?.toIso8601String(),
      },
      'reportedLostItems': itemsService.items.map((i) => i.toMap()).toList(),
      'foundItemsLogged': itemsService.foundItems.map((f) => f.toMap()).toList(),
      'ledgerTransactions': itemsService.claims.map((c) => c.toMap()).toList(),
      'systemNotifications': itemsService.notifications.map((n) => n.toMap()).toList(),
      'privacyNotice': 'Special-category biometric data is strictly hashed and can be purged upon request under Article 17.',
    };
  }
}
