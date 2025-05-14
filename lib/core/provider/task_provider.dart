import 'dart:core';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../data/modal/task_modal.dart';
import '../../presentations/view/home_page.dart';
import '../../presentations/view/task_filter_chip.dart';
import '../constants/app_constants.dart';



class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  final pb = PocketBase(AppConstants.pocketBaseUrl);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Initialize tasks from local storage or other sources
  Future<void> initTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      // We'll fetch tasks from PocketBase here
      await fetchTasks();
    } catch (e) {
      _error = 'Failed to initialize tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  TaskFilter _currentFilter = TaskFilter.all;
  TaskFilter get currentFilter => _currentFilter;

  List<Task> get filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.pending:
        return _tasks.where((task) => task.status == 'pending').toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.status == 'completed').toList();
      case TaskFilter.expired:
        return _tasks.where((task) => task.status == 'expired').toList();
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if user is authenticated
      if (!pb.authStore.isValid) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final userId = pb.authStore.model.id;

      // Fetch tasks from PocketBase
      final result = await pb.collection('tasks').getList(
        filter: 'user = "$userId"',
        sort: 'deadline',
      );

      // Convert to Task objects
      _tasks = result.items.map((item) {
        Map<String, dynamic> data = item.toJson();
        // Add the id to the data
        data['id'] = item.id;

        // Update expired status for tasks that have passed their deadline
        if (data['status'] == 'pending' &&
            DateTime.parse(data['deadline']).isBefore(DateTime.now())) {
          data['status'] = 'expired';
          // Update in PocketBase
          _updateTaskStatus(item.id, 'expired');
        }

        return Task.fromJson(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch tasks: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(String title, String? description, DateTime deadline) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = pb.authStore.model.id;

      final data = {
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'isCompleted': false,
        'status': 'pending',
        'user': userId,
      };

      final record = await pb.collection('tasks').create(body: data);

      // Add the new task to the list
      Map<String, dynamic> taskData = record.toJson();
      taskData['id'] = record.id;
      _tasks.add(Task.fromJson(taskData));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add task: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markTaskCompleted(String taskId) async {
    try {
      await pb.collection('tasks').update(taskId, body: {
        'isCompleted': true,
        'status': 'completed',
      });

      // Update the task in the local list
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: true,
          status: 'completed',
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to mark task as completed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _updateTaskStatus(String taskId, String status) async {
    try {
      await pb.collection('tasks').update(taskId, body: {
        'status': status,
      });
    } catch (e) {
      print('Failed to update task status: $e');
    }
  }

  Future<bool> updateTask(String taskId, String title, String? description, DateTime deadline) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = {
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        // Keep the existing status
      };

      await pb.collection('tasks').update(taskId, body: data);

      // Update the task in the local list
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          title: title,
          description: description,
          deadline: deadline,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update task: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delete the task from PocketBase
      await pb.collection('tasks').delete(taskId);

      // Remove the task from the local list
      _tasks.removeWhere((task) => task.id == taskId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete task: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkExpiredTasks() async {
    final now = DateTime.now();
    bool hasChanges = false;

    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].status == 'pending' && _tasks[i].deadline.isBefore(now)) {
        // Update task status to expired
        _tasks[i] = _tasks[i].copyWith(status: 'expired');

        // Update in PocketBase
        await _updateTaskStatus(_tasks[i].id, 'expired');

        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void logout() {
    pb.authStore.clear();
    _tasks = [];
    notifyListeners();
  }
}