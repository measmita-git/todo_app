

import '../../core/constants/app_constants.dart';
import '../../core/utils/date.dart' as date_util;

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final bool isCompleted;
  final String status;
  final String userId;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.isCompleted,
    required this.status,
    required this.userId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final DateTime deadline = DateTime.parse(json['deadline']);
    String status = json['status'];

    // Check if task should be marked as expired
    if (status == AppConstants.pending && date_util.DateUtils.isExpired(deadline)) {
      status = AppConstants.expired;
    }

    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: deadline,
      isCompleted: json['isCompleted'] ?? false,
      status: status,
      userId: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
      'status': status,
      'user': userId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    String? status,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }
}