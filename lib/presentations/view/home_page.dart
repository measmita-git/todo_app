import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/provider/auth_provider.dart';
import '../../core/provider/task_provider.dart';
import '../widgets/task_filter_chip.dart';
import 'auth/login_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // const TaskListPage(),
    Container(), // Placeholder for the add task button
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deadline Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).fetchTasks();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _currentIndex == 0
          ? Column(
        children: [
          const TaskFilterChips(),
          Expanded(child: _pages[_currentIndex]),
        ],
      )
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigate to add task page
            // _navigateToAddTask();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Task',
          ),
        ],
      ),
    );
  }

  // void _navigateToAddTask() async {
  //   // Navigate to add task page and refresh tasks when returning
  //   // final result = await Navigator.push(
  //   //   context,
  //   //   // MaterialPageRoute(builder: (context) => const AddTaskPage()),
  //   // );
  //
  //   if (result == true) {
  //     // Task was added, refresh the task list
  //     Provider.of<TaskProvider>(context, listen: false).fetchTasks();
  //   }
  // }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;

    // Navigate to login page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}