import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/provider/task_provider.dart';

class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'All',
                  taskProvider.currentFilter == TaskFilter.all,
                      () => taskProvider.setFilter(TaskFilter.all),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Pending',
                  taskProvider.currentFilter == TaskFilter.pending,
                      () => taskProvider.setFilter(TaskFilter.pending),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Completed',
                  taskProvider.currentFilter == TaskFilter.completed,
                      () => taskProvider.setFilter(TaskFilter.completed),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Expired',
                  taskProvider.currentFilter == TaskFilter.expired,
                      () => taskProvider.setFilter(TaskFilter.expired),
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
      bool isSelected,
      VoidCallback onTap,
      ) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.chipTheme.backgroundColor,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      showCheckmark: true,
    );
  }
}