import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/modal/task_modal.dart';
import '../../data/repositories/task_repository.dart';
import '../constants/app_constants.dart';
import '../utils/date.dart' as date_util;

enum TaskFilter { all, pending, completed, expired }

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();

  List<TaskModel> _tasks = [];
  List<TaskModel> _filteredTasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _expiryCheckTimer;

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get filteredTasks => _filteredTasks;
  TaskFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TaskProvider() {
    // Start a timer to check for expired tasks periodically
    _expiryCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkExpiredTasks();
    });
  }

  @override
  void dispose() {
    _expiryCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> initTasks() async {
    await fetchTasks();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskRepository.getTasks();

      // Check for expired tasks
      _tasks = await _taskRepository.checkAndUpdateExpiredTasks(_tasks);

      _applyFilter();
      _scheduleNotifications();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    switch (_currentFilter) {
      case TaskFilter.all:
        _filteredTasks = List.from(_tasks);
        break;
      case TaskFilter.pending:
        _filteredTasks =
            _tasks
                .where((task) => task.status == AppConstants.pending)
                .toList();
        break;
      case TaskFilter.completed:
        _filteredTasks =
            _tasks
                .where((task) => task.status == AppConstants.completed)
                .toList();
        break;
      case TaskFilter.expired:
        _filteredTasks =
            _tasks
                .where((task) => task.status == AppConstants.expired)
                .toList();
        break;
    }
  }

  Future<void> addTask(
    String title,
    String? description,
    DateTime deadline,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTask = await _taskRepository.createTask(
        title: title,
        description: description,
        deadline: deadline,
      );

      _tasks.add(newTask);
      _applyFilter();
      _scheduleNotification(newTask);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markTaskAsCompleted(TaskModel task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await _taskRepository.markTaskAsCompleted(task);

      // Update the task in the list
      _tasks =
          _tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
      _applyFilter();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _taskRepository.deleteTask(id);

      // Remove the task from the list
      _tasks.removeWhere((task) => task.id == id);
      _applyFilter();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _checkExpiredTasks() async {
    final expiredTasks =
        _tasks
            .where(
              (task) =>
                  task.status == AppConstants.pending &&
                  date_util.DateUtils.isExpired(task.deadline),
            )
            .toList();

    if (expiredTasks.isNotEmpty) {
      for (final task in expiredTasks) {
        try {
          final updatedTask = await _taskRepository.markTaskAsExpired(task);
          _tasks =
              _tasks
                  .map((t) => t.id == updatedTask.id ? updatedTask : t)
                  .toList();
        } catch (e) {
          debugPrint('Error marking task as expired: ${e.toString()}');
        }
      }

      _applyFilter();
      notifyListeners();
    }
  }

  Future<void> _scheduleNotifications() async {
    // Cancel any existing notifications first
    // await flutterLocalNotificationsPlugin.cancelAll();

    // Schedule notifications for pending tasks
    final pendingTasks =
        _tasks.where((task) => task.status == AppConstants.pending).toList();

    for (final task in pendingTasks) {
      await _scheduleNotification(task);
    }
  }

  Future<void> _scheduleNotification(TaskModel task) async {
    // Only schedule notifications for pending tasks
    if (task.status != AppConstants.pending) return;

    // Calculate time until one hour before deadline
    final duration = date_util.DateUtils.timeUntilOneHourBefore(task.deadline);

    // Only schedule if the deadline is in the future
    if (duration.isNegative) return;

    // Create the notification details
    // const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //   'task_reminders',
    //   'Task Reminders',
    //   channelDescription: 'Notifications for task deadlines',
    //   importance: Importance.high,
    //   priority: Priority.high,
    // );

    // const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );

    // const NotificationDetails platformChannelSpecifics = NotificationDetails(
    //   android: androidPlatformChannelSpecifics,
    //   iOS: iOSPlatformChannelSpecifics,
    // );

    // Schedule the notification
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   int.parse(task.id.substring(0, 8), radix: 16), // Convert first 8 chars of ID to int for unique ID
    //   'Task Reminder: ${task.title}',
    //   'Your task is due in 1 hour',
    //   tz.TZDateTime.now(tz.local).add(duration),
    //   platformChannelSpecifics,
    //   androidAllowWhileIdle: true,
    //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    // );
  }
}
