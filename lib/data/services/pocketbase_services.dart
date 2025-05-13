import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';

class PocketBaseService {
  static late PocketBase _pb;
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _pb = PocketBase(AppConstants.pocketBaseUrl);
    _prefs = await SharedPreferences.getInstance();

    // Try to restore auth if exists
    final token = _prefs.getString(AppConstants.authTokenKey);
    if (token != null) {
      try {
        // This will load the user data from the provided token
        await _pb.collection('users').authRefresh();
      } catch (e) {
        // Invalid or expired token, clear any stored auth data
        await clearAuthData();
      }
    }
  }

  static PocketBase get instance => _pb;

  static bool get isAuthenticated => _pb.authStore.isValid;

  static String? get userId => _pb.authStore.model?.id;

  static Future<void> saveAuthData() async {
    await _prefs.setString(AppConstants.authTokenKey, _pb.authStore.token);
    await _prefs.setString(
      AppConstants.userIdKey,
      _pb.authStore.model?.id ?? '',
    );
  }

  static Future<void> clearAuthData() async {
    _pb.authStore.clear();
    await _prefs.remove(AppConstants.authTokenKey);
    await _prefs.remove(AppConstants.userIdKey);
  }

  static Future<RecordModel> signUp(
    String email,
    String password,
    String passwordConfirm,
  ) async {
    try {
      final record = await _pb
          .collection('users')
          .create(
            body: {
              'email': email,
              'password': password,
              'passwordConfirm': passwordConfirm,
            },
          );

      // After signup, we need to login
      await _pb.collection('users').authWithPassword(email, password);
      await saveAuthData();

      return record;
    } catch (e) {
      throw AuthException('Failed to sign up: ${e.toString()}');
    }
  }

  static Future<RecordAuth> login(String email, String password) async {
    try {
      final record = await _pb
          .collection('users')
          .authWithPassword(email, password);
      await saveAuthData();
      return record;
    } catch (e) {
      throw AuthException('Failed to login: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    try {
      _pb.authStore.clear();
      await clearAuthData();
    } catch (e) {
      throw AuthException('Failed to logout: ${e.toString()}');
    }
  }

  static Future<List<RecordModel>> getTasks() async {
    if (!isAuthenticated) {
      throw AuthException('User not authenticated');
    }

    try {
      final records = await _pb
          .collection(AppConstants.tasksCollection)
          .getList(filter: 'user = "$userId"', sort: '-created');
      return records.items;
    } catch (e) {
      throw TaskException('Failed to get tasks: ${e.toString()}');
    }
  }

  static Future<RecordModel> createTask(Map<String, dynamic> taskData) async {
    if (!isAuthenticated) {
      throw AuthException('User not authenticated');
    }

    try {
      // Add the user ID to the task data
      taskData['user'] = userId;

      return await _pb
          .collection(AppConstants.tasksCollection)
          .create(body: taskData);
    } catch (e) {
      throw TaskException('Failed to create task: ${e.toString()}');
    }
  }

  static Future<RecordModel> updateTask(
    String id,
    Map<String, dynamic> taskData,
  ) async {
    if (!isAuthenticated) {
      throw AuthException('User not authenticated');
    }

    try {
      return await _pb
          .collection(AppConstants.tasksCollection)
          .update(id, body: taskData);
    } catch (e) {
      throw TaskException('Failed to update task: ${e.toString()}');
    }
  }

  static Future<void> deleteTask(String id) async {
    if (!isAuthenticated) {
      throw AuthException('User not authenticated');
    }

    try {
      await _pb.collection(AppConstants.tasksCollection).delete(id);
    } catch (e) {
      throw TaskException('Failed to delete task: ${e.toString()}');
    }
  }
}
