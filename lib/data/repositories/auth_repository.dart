import '../../core/error/exceptions.dart';
import '../services/pocketbase_services.dart';

class AuthRepository {
  // Property to get the current user ID
  String? get userId => PocketBaseService.userId;

  // Check if user is logged in
  Future<bool> checkUserLoggedIn() async {
    try {
      return await Future.delayed(
        const Duration(milliseconds: 500),
        () => PocketBaseService.isAuthenticated,
      );
    } catch (e) {
      throw AuthException('Failed to check authentication status: $e');
    }
  }

  // Sign up new user
  Future<void> signUp(
    String email,
    String password,
    String passwordConfirm,
  ) async {
    if (password != passwordConfirm) {
      throw AuthException('Passwords do not match');
    }

    try {
      await PocketBaseService.signUp(email, password, passwordConfirm);
    } catch (e) {
      throw AuthException('Registration failed: $e');
    }
  }

  // Login user
  Future<void> login(String email, String password) async {
    try {
      final result = await PocketBaseService.login(email, password);
      // Check if login was successful using safer type checking
      final bool success = (result != null); // not nullable ma nul check garya, why> hijo error dekhairathyo maile arko main file nbata call garda

      if (!success) {
        throw AuthException('Login failed. Please check your credentials.');
      }
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await PocketBaseService.logout();
    } catch (e) {
      throw AuthException('Logout failed: $e');
    }
  }
}
