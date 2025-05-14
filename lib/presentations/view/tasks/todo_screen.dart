import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../data/modal/task_modal.dart';
import '../../../main.dart';
import '../home_page.dart';

import 'package:provider/provider.dart';
import '../../../core/provider/task_provider.dart';


class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with WidgetsBindingObserver {
  String filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial fetch of tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh tasks when app is resumed
      Provider.of<TaskProvider>(context, listen: false).checkExpiredTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('My Tasks', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[600]),
            onPressed: () => Provider.of<TaskProvider>(context, listen: false).fetchTasks(),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[600]),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, _) {
                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredTasks = _getFilteredTasks(taskProvider);

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No ${filter.toLowerCase()} tasks found',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (_, i) {
                    final task = filteredTasks[i];
                    return _buildTaskCard(task);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 8.0,
        children: ['all', 'pending', 'completed', 'expired'].map((f) {
          return ChoiceChip(
            label: Text(f[0].toUpperCase() + f.substring(1)),
            selected: filter == f,
            onSelected: (_) => setState(() => filter = f),
          );
        }).toList(),
      ),
    );
  }

  List<Task> _getFilteredTasks(TaskProvider provider) {
    switch (filter) {
      case 'pending':
        return provider.tasks.where((t) => t.status == 'pending').toList();
      case 'completed':
        return provider.tasks.where((t) => t.status == 'completed').toList();
      case 'expired':
        return provider.tasks.where((t) => t.status == 'expired').toList();
      default:
        return provider.tasks;
    }
  }

  Widget _buildTaskCard(Task task) {
    Color statusColor;
    switch (task.status) {
      case 'pending':
        statusColor = Colors.yellow;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'expired':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.yMd().add_jm().format(task.deadline),
              style: const TextStyle(color: Colors.grey),
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(task.description!),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(task.status.toUpperCase()),
                  backgroundColor: statusColor.withOpacity(0.2),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _addOrEditTask(task),
                    ),
                    if (task.status == 'pending')
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _markTaskCompleted(task.id),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteTask(task),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addOrEditTask([Task? task]) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskModal(task: task),
    );

    if (result != null) {
      if (task != null) {
        // Edit existing task
        Provider.of<TaskProvider>(context, listen: false).updateTask(
          task.id,
          result['title'],
          result['description'],
          result['deadline'],
        );
      } else {
        // Add new task
        Provider.of<TaskProvider>(context, listen: false).addTask(
          result['title'],
          result['description'],
          result['deadline'],
        );
      }
    }
  }

  void _markTaskCompleted(String taskId) {
    Provider.of<TaskProvider>(context, listen: false).markTaskCompleted(taskId);
  }

  void _confirmDeleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class TaskModal extends StatefulWidget {
  final Task? task;
  const TaskModal({super.key, this.task});

  @override
  State<TaskModal> createState() => _TaskModalState();
}

class _TaskModalState extends State<TaskModal> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime? deadline;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      if (widget.task!.description != null) {
        descController.text = widget.task!.description!;
      }
      deadline = widget.task!.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.task == null ? 'Add Task' : 'Edit Task',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  deadline == null
                      ? 'Pick Deadline'
                      : DateFormat.yMd().add_jm().format(deadline!),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date == null) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time == null) return;
                  setState(
                        () => deadline = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || deadline == null) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Title and deadline are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(
                context,
                {
                  'title': titleController.text,
                  'description': descController.text.isNotEmpty ? descController.text : null,
                  'deadline': deadline,
                },
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
