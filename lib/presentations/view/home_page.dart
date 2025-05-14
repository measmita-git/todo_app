// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:pocketbase/pocketbase.dart';
// import 'package:provider/provider.dart';
// import '../../core/provider/auth_provider.dart';
// import '../../core/provider/task_provider.dart';
// import '../widgets/task_filter_chip.dart';
// import 'auth/login_screen.dart';
//
// final PocketBase pb = PocketBase('http://127.0.0.1:8090');
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;
//
//   final List<Widget> _pages = [
//     const TaskListPage(),
//     Container(), // Placeholder for the add task button
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Todo App'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               Provider.of<TaskProvider>(context, listen: false).fetchTasks();
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               logout();
//             },
//           ),
//         ],
//       ),
//       body:
//           _currentIndex == 0
//               ? Column(
//                 children: [
//                   const TaskFilterChips(),
//                   Expanded(child: _pages[_currentIndex]),
//                 ],
//               )
//               : _pages[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           if (index == 1) {
//             // Navigate to add task page
//             // _navigateToAddTask();
//           } else {
//             setState(() {
//               _currentIndex = index;
//             });
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
//           BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Task'),
//         ],
//       ),
//     );
//   }
//
//  //  void _navigateToAddTask() async {
//  //    // Navigate to add task page and refresh tasks when returning
//  //    final result = await Navigator.push(
//  //      context,
//  //      MaterialPageRoute(builder: (context) => const AddTaskPage()),
//  //    );
//  // // pocketbase connection resolve vayo, baki you can do. best of luck.
//  //    if (result == true) {
//  //      // Task was added, refresh the task list
//  //      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
//  //    }
//  //  }
//
//   void _handleLogout() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.logout();
//
//     if (!mounted) return;
//
//     // Navigate to login page
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const LoginPage()),
//     );
//   }
//
//   static void logout() {
//     pb.authStore.clear();
//   }
// }
//
//
//
//
//
//
// class TaskFilterChips extends StatelessWidget {
//   const TaskFilterChips({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TaskProvider>(
//       builder: (context, taskProvider, _) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildFilterChip(
//                   context,
//                   'All',
//                   TaskFilter.all,
//                   taskProvider,
//                 ),
//                 const SizedBox(width: 8),
//                 _buildFilterChip(
//                   context,
//                   'Pending',
//                   TaskFilter.pending,
//                   taskProvider,
//                 ),
//                 const SizedBox(width: 8),
//                 _buildFilterChip(
//                   context,
//                   'Completed',
//                   TaskFilter.completed,
//                   taskProvider,
//                 ),
//                 const SizedBox(width: 8),
//                 _buildFilterChip(
//                   context,
//                   'Expired',
//                   TaskFilter.expired,
//                   taskProvider,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildFilterChip(
//       BuildContext context,
//       String label,
//       TaskFilter filter,
//       TaskProvider taskProvider,
//       ) {
//     final isSelected = taskProvider.currentFilter == filter;
//
//     return FilterChip(
//       label: Text(label),
//       selected: isSelected,
//       onSelected: (_) {
//         // taskProvider.setFilter();
//       },
//       backgroundColor: Colors.grey.shade200,
//       selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
//       checkmarkColor: Theme.of(context).primaryColor,
//     );
//   }
// }
//
// enum TaskFilter {
//   all,
//   pending,
//   completed,
//   expired,
// }
//
// class Task {
//   final String id;
//   final String title;
//   final String? description;
//   final DateTime deadline;
//   final bool isCompleted;
//   late final String status; // pending, completed, expired
//   final String userId;
//
//   Task({
//     required this.id,
//     required this.title,
//     this.description,
//     required this.deadline,
//     required this.isCompleted,
//     required this.status,
//     required this.userId,
//   });
//
//   factory Task.fromJson(Map<String, dynamic> json) {
//     return Task(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'],
//       deadline: DateTime.parse(json['deadline']),
//       isCompleted: json['isCompleted'],
//       status: json['status'],
//       userId: json['user'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'deadline': deadline.toIso8601String(),
//       'isCompleted': isCompleted,
//       'status': status,
//       'user': userId,
//     };
//   }
//
//   Task copyWith({
//     String? id,
//     String? title,
//     String? description,
//     DateTime? deadline,
//     bool? isCompleted,
//     String? status,
//     String? userId,
//   }) {
//     return Task(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       deadline: deadline ?? this.deadline,
//       isCompleted: isCompleted ?? this.isCompleted,
//       status: status ?? this.status,
//       userId: userId ?? this.userId,
//     );
//   }
// }
//
// class TaskListPage extends StatefulWidget {
//   const TaskListPage({super.key});
//
//   @override
//   State<TaskListPage> createState() => _TaskListPageState();
// }
//
// class _TaskListPageState extends State<TaskListPage> {
//   late Timer _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch tasks when page loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<TaskProvider>(context, listen: false).fetchTasks();
//     });
//
//     // Set up timer to check for expired tasks every minute
//     _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       if (mounted) {
//         Provider.of<TaskProvider>(context, listen: false).checkExpiredTasks();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TaskProvider>(
//       builder: (context, taskProvider, _) {
//         if (taskProvider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (taskProvider.error != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Error: ${taskProvider.error}',
//                   style: const TextStyle(color: Colors.red),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => taskProvider.fetchTasks(),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         final tasks = taskProvider.filteredTasks;
//
//         if (tasks.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No ${taskProvider.currentFilter.name} tasks found',
//                   style: const TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return RefreshIndicator(
//           onRefresh: () => taskProvider.fetchTasks(),
//           child: ListView.builder(
//             itemCount: tasks.length,
//             itemBuilder: (context, index) {
//               final task = tasks[index];
//               return TaskListItem(task: task);
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// class TaskListItem extends StatelessWidget {
//   final Task task;
//
//   const TaskListItem({super.key, required this.task});
//
//   @override
//   Widget build(BuildContext context) {
//     final Color statusColor = _getStatusColor(task.status);
//     final bool isOverdue = task.status == 'pending' &&
//         task.deadline.isBefore(DateTime.now());
//
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         title: Text(
//           task.title,
//           style: TextStyle(
//             decoration: task.isCompleted ? TextDecoration.lineThrough : null,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (task.description != null && task.description!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(task.description!),
//               ),
//             Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Row(
//                 children: [
//                   const Icon(Icons.access_time, size: 16),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${_formatDate(task.deadline)}',
//                     style: TextStyle(
//                       color: isOverdue ? Colors.red : null,
//                       fontWeight: isOverdue ? FontWeight.bold : null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: statusColor.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 task.status.toUpperCase(),
//                 style: TextStyle(
//                   color: statusColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//             if (task.status == 'pending')
//               IconButton(
//                 icon: const Icon(Icons.check_circle_outline),
//                 color: Colors.green,
//                 onPressed: () {
//                   _markTaskCompleted(context, task.id);
//                 },
//               ),
//           ],
//         ),
//         onLongPress: () {
//           _showDeleteConfirmation(context, task);
//         },
//       ),
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.blue;
//       case 'completed':
//         return Colors.green;
//       case 'expired':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final tomorrow = today.add(const Duration(days: 1));
//     final dateToCheck = DateTime(date.year, date.month, date.day);
//
//     if (dateToCheck == today) {
//       return 'Today at ${_formatTime(date)}';
//     } else if (dateToCheck == tomorrow) {
//       return 'Tomorrow at ${_formatTime(date)}';
//     } else {
//       return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
//     }
//   }
//
//   String _formatTime(DateTime date) {
//     final hour = date.hour.toString().padLeft(2, '0');
//     final minute = date.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }
//
//   void _markTaskCompleted(BuildContext context, String taskId) {
//     Provider.of<TaskProvider>(context, listen: false).markTaskCompleted(taskId);
//   }
//
//   void _showDeleteConfirmation(BuildContext context, Task task) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Task'),
//         content: Text('Are you sure you want to delete "${task.title}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
//             },
//             child: const Text('DELETE', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }