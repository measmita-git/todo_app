 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/provider/task_provider.dart';

class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'All',
                  TaskFilter.all,
                  taskProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Pending',
                  TaskFilter.pending,
                  taskProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Completed',
                  TaskFilter.completed,
                  taskProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Expired',
                  TaskFilter.expired,
                  taskProvider,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
      BuildContext context,
      String label,
      TaskFilter filter,
      TaskProvider taskProvider,
      ) {
    final isSelected = taskProvider.currentFilter == filter;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        // taskProvider.setFilter();
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}

enum TaskFilter {
  all,
  pending,
  completed,
  expired,
}