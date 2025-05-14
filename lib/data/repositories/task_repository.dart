// import '../../core/constants/app_constants.dart';
// import '../../core/error/exceptions.dart';
// import '../../core/utils/date.dart' as date_util;
// import '../modal/task_modal.dart';
// import '../services/pocketbase_services.dart';
//
// class TaskRepository {
//   Future<List<TaskModel>> getTasks() async {
//     try {
//       final records = await PocketBaseService.getTasks();
//
//       return records.map((record) {
//         // Convert record to map
//         final Map<String, dynamic> data = record.toJson();
//         // Add id to the map
//         data['id'] = record.id;
//         // Return TaskModel
//         return TaskModel.fromJson(data);
//       }).toList();
//     } catch (e) {
//       throw TaskException('Failed to get tasks: ${e.toString()}');
//     }
//   }
//
//   Future<TaskModel> createTask({
//     required String title,
//     String? description,
//     required DateTime deadline,
//   }) async {
//     try {
//       final taskData = {
//         'title': title,
//         'description': description,
//         'deadline': deadline.toIso8601String(),
//         'isCompleted': false,
//         'status': AppConstants.pending,
//       };
//
//       final record = await PocketBaseService.createTask(taskData);
//
//       // Convert record to map
//       final Map<String, dynamic> data = record.toJson();
//       // Add id to the map
//       data['id'] = record.id;
//
//       // Return TaskModel
//       return TaskModel.fromJson(data);
//     } catch (e) {
//       throw TaskException('Failed to create task: ${e.toString()}');
//     }
//   }
//
//   Future<TaskModel> markTaskAsCompleted(TaskModel task) async {
//     try {
//       final taskData = {'isCompleted': true, 'status': AppConstants.completed};
//
//       final record = await PocketBaseService.updateTask(task.id, taskData);
//
//       // Convert record to map
//       final Map<String, dynamic> data = record.toJson();
//       // Add id to the map
//       data['id'] = record.id;
//
//       // Return TaskModel
//       return TaskModel.fromJson(data);
//     } catch (e) {
//       throw TaskException('Failed to mark task as completed: ${e.toString()}');
//     }
//   }
//
//   Future<TaskModel> markTaskAsExpired(TaskModel task) async {
//     try {
//       final taskData = {'status': AppConstants.expired};
//
//       final record = await PocketBaseService.updateTask(task.id, taskData);
//
//       // Convert record to map
//       final Map<String, dynamic> data = record.toJson();
//       // Add id to the map
//       data['id'] = record.id;
//
//       // Return TaskModel
//       return TaskModel.fromJson(data);
//     } catch (e) {
//       throw TaskException('Failed to mark task as expired: ${e.toString()}');
//     }
//   }
//
//   Future<void> deleteTask(String id) async {
//     try {
//       await PocketBaseService.deleteTask(id);
//     } catch (e) {
//       throw TaskException('Failed to delete task: ${e.toString()}');
//     }
//   }
//
//   Future<List<TaskModel>> checkAndUpdateExpiredTasks(
//     List<TaskModel> tasks,
//   ) async {
//     final List<TaskModel> updatedTasks = [];
//
//     for (final task in tasks) {
//       if (task.status == AppConstants.pending &&
//           date_util.DateUtils.isExpired(task.deadline)) {
//         try {
//           final updatedTask = await markTaskAsExpired(task);
//           updatedTasks.add(updatedTask);
//         } catch (e) {
//           // If update fails, add the original task
//           updatedTasks.add(task);
//         }
//       } else {
//         updatedTasks.add(task);
//       }
//     }
//
//     return updatedTasks;
//   }
// }
