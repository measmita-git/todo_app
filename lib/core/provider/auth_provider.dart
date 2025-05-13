import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../error/exceptions.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthProvider with ChangeNotifier {
  // Use lazy initialization for the repository to avoid circular dependencies
  late final AuthRepository authRepository;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get userId => authRepository.userId;

  // Constructor without any auto-initialization to prevent stack overflow
  AuthProvider() {
    // Initialize the repository but DO NOT call any methods that could create
    // cyclic dependencies or trigger notifications during construction
    authRepository = AuthRepository();
  }

  // Initialize without notifying listeners
  void _setStatus(AuthStatus newStatus) {
    _status = newStatus;
  }

  // Update with notification
  void updateStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  Future<bool> checkUserLoggedIn() async {
    // Don't call notifyListeners right away to avoid build-time issues
    _setStatus(AuthStatus.loading);

    try {
      final isLoggedIn = await authRepository.checkUserLoggedIn();
      _status =
          isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
      return isLoggedIn;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String passwordConfirm,
  ) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      await authRepository.signUp(email, password, passwordConfirm);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      await authRepository.login(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _setStatus(AuthStatus.loading);

    try {
      await authRepository.logout();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
