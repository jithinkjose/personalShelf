import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService.instance;

  bool _loading = false;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _auth.isLoggedIn;
  UserModel? get currentUser => _auth.currentUser;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void clearError() => _setError(null);

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    final result = await _auth.login(email: email, password: password);
    _setLoading(false);

    switch (result) {
      case AuthResult.success:
        notifyListeners();
        return true;
      case AuthResult.userNotFound:
        _setError('No account found with this email.');
        return false;
      case AuthResult.invalidCredentials:
        _setError('Incorrect password. Please try again.');
        return false;
      case AuthResult.invalidEmail:
        _setError('Please enter a valid email address.');
        return false;
      default:
        _setError('Login failed. Please try again.');
        return false;
    }
  }

  Future<bool> register(String email, String name, String password) async {
    _setLoading(true);
    _setError(null);
    final result = await _auth.register(email: email, name: name, password: password);
    _setLoading(false);

    switch (result) {
      case AuthResult.success:
        notifyListeners();
        return true;
      case AuthResult.emailAlreadyExists:
        _setError('An account with this email already exists.');
        return false;
      case AuthResult.weakPassword:
        _setError('Password must be at least 6 characters.');
        return false;
      case AuthResult.invalidEmail:
        _setError('Please enter a valid email address.');
        return false;
      default:
        _setError('Registration failed. Please try again.');
        return false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    notifyListeners();
  }

  Future<bool> changePassword(String current, String newPass) async {
    _setLoading(true);
    final result = await _auth.changePassword(
      currentPassword: current,
      newPassword: newPass,
    );
    _setLoading(false);

    if (result == AuthResult.success) return true;
    if (result == AuthResult.invalidCredentials) {
      _setError('Current password is incorrect.');
    } else if (result == AuthResult.weakPassword) {
      _setError('New password must be at least 6 characters.');
    }
    return false;
  }
}
