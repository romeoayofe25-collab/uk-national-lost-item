import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

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
}
