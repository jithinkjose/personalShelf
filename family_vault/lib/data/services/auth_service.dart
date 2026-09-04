import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'storage_service.dart';
import '../../core/constants/app_constants.dart';

enum AuthResult {
  success,
  invalidCredentials,
  emailAlreadyExists,
  weakPassword,
  invalidEmail,
  userNotFound,
}

class AuthService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  final _storage = StorageService.instance;
  final _uuid = const Uuid();

  String? _currentUserId;

  Future<void> init() async {
    _currentUserId = await _secureStorage.read(key: AppConstants.currentUserKey);
  }

  bool get isLoggedIn => _currentUserId != null;

  UserModel? get currentUser {
    if (_currentUserId == null) return null;
    return _storage.getUserById(_currentUserId!);
  }

  Future<AuthResult> register({
    required String email,
    required String name,
    required String password,
  }) async {
    if (!_isValidEmail(email)) return AuthResult.invalidEmail;
    if (password.length < 6) return AuthResult.weakPassword;

    final existing = _storage.getUserByEmail(email);
    if (existing != null) return AuthResult.emailAlreadyExists;

    final hash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 10));
    final now = DateTime.now();
    final user = UserModel(
      id: _uuid.v4(),
      email: email.trim().toLowerCase(),
      name: name.trim(),
      passwordHash: hash,
      createdAt: now,
      lastLoginAt: now,
    );

    await _storage.saveUser(user);
    await _setCurrentUser(user.id);
    return AuthResult.success;
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) return AuthResult.invalidEmail;

    final user = _storage.getUserByEmail(email.trim().toLowerCase());
    if (user == null) return AuthResult.userNotFound;

    final match = BCrypt.checkpw(password, user.passwordHash);
    if (!match) return AuthResult.invalidCredentials;

    final updated = user.copyWith(lastLoginAt: DateTime.now());
    await _storage.saveUser(updated);
    await _setCurrentUser(user.id);
    return AuthResult.success;
  }

  Future<void> logout() async {
    _currentUserId = null;
    await _secureStorage.delete(key: AppConstants.currentUserKey);
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null) return AuthResult.userNotFound;
    if (newPassword.length < 6) return AuthResult.weakPassword;

    final match = BCrypt.checkpw(currentPassword, user.passwordHash);
    if (!match) return AuthResult.invalidCredentials;

    final hash = BCrypt.hashpw(newPassword, BCrypt.gensalt(logRounds: 10));
    await _storage.saveUser(user.copyWith(passwordHash: hash));
    return AuthResult.success;
  }

  Future<void> _setCurrentUser(String userId) async {
    _currentUserId = userId;
    await _secureStorage.write(key: AppConstants.currentUserKey, value: userId);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email.trim());
  }
}
