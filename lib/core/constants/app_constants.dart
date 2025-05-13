class AppConstants {
  // PocketBase
  static const String pocketBaseUrl = 'http://127.0.0.1:8090/';
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

  // Task Status
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String expired = 'expired';

  // Shared Preferences Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // Notification IDs
  static const int taskReminderNotificationId = 1;
}
