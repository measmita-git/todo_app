class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final bool isCompleted;
  late final String status; // pending, completed, expired
  final String userId;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.isCompleted,
    required this.status,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['isCompleted'],
      status: json['status'],
      userId: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
      'status': status,
      'user': userId,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    String? status,
    String? userId,
  }) {
    return Task(
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