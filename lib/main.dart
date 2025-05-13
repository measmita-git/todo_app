import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'task_reminder_channel',
      channelName: 'Task Reminders',
      channelDescription: 'Reminds when a task is about to expire',
      defaultColor: Colors.teal,
      importance: NotificationImportance.High,
      channelShowBadge: true,
    ),
  ], debug: true);

  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Todo App',
      home: AuthScreen(),
    );
  }
}

class Task {
  String id;
  String title;
  String description;
  DateTime deadline;
  String status; // pending, completed, expired

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
  });
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? authError;

  void handleAuth() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => authError = 'Please fill in all fields');
      return;
    }

    // Simulated PocketBase auth (replace with real implementation)
    if (isLogin) {
      if (email == 'user@test.com' && password == '123456') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TodoScreen()),
        );
      } else {
        setState(() => authError = 'Invalid credentials');
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TodoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text(
                'Welcome to Todo App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => isLogin = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isLogin ? Colors.grey[800] : Colors.grey[300],
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: isLogin ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => isLogin = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isLogin ? Colors.grey[800] : Colors.grey[300],
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: !isLogin ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (authError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(authError!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                ),
                child: Text(isLogin ? 'Login' : 'Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with WidgetsBindingObserver {
  List<Task> tasks = [];
  String filter = 'all';
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkExpiry();
    scheduleNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkExpiry();
      scheduleNotifications();
    }
  }

  void scheduleNotifications() async {
    for (var task in tasks) {
      if (task.status == 'pending') {
        final timeLeft = task.deadline.difference(DateTime.now());
        if (timeLeft.inMinutes <= 60 && timeLeft.inMinutes > 0) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: task.id.hashCode,
              channelKey: 'task_reminder_channel',
              title: '⏰ Task Reminder',
              body: '"${task.title}" is due in less than an hour!',
              notificationLayout: NotificationLayout.Default,
            ),
            schedule: NotificationCalendar.fromDate(
              date: task.deadline.subtract(Duration(hours: 1)).toLocal(),
              preciseAlarm: true,
            ),
          );
        }
      }
    }
  }

  void checkExpiry() {
    final now = DateTime.now();
    for (var task in tasks) {
      if (task.status == 'pending' && task.deadline.isBefore(now)) {
        task.status = 'expired';
      }
    }
    setState(() {});
  }

  void addOrEditTask([Task? task]) async {
    final result = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskModal(task: task),
    );

    if (result != null) {
      setState(() {
        if (task != null) {
          tasks[tasks.indexWhere((t) => t.id == task.id)] = result;
        } else {
          tasks.add(result);
        }
        checkExpiry();
        scheduleNotifications();
      });
    }
  }

  List<Task> get filteredTasks {
    switch (filter) {
      case 'pending':
      case 'completed':
      case 'expired':
        return tasks.where((t) => t.status == filter).toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('My Tasks', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[600]),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 8.0,
              children:
                  ['all', 'pending', 'completed', 'expired'].map((f) {
                    return ChoiceChip(
                      label: Text(f[0].toUpperCase() + f.substring(1)),
                      selected: filter == f,
                      onSelected: (_) => setState(() => filter = f),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child:
                filteredTasks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lottie.asset(
                          //   'assets/empty.gif',
                          //   width: 200,
                          //   height: 200,
                          // ),
                          SizedBox(height: 12),
                          Text(
                            'No tasks found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (_, i) {
                        final t = filteredTasks[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat.yMd().add_jm().format(t.deadline),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(t.description),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                      label: Text(t.status.toUpperCase()),
                                      backgroundColor:
                                          t.status == 'pending'
                                              ? Colors.yellow[100]
                                              : t.status == 'completed'
                                              ? Colors.green[100]
                                              : Colors.red[100],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => addOrEditTask(t),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed:
                                              () => setState(
                                                () => t.status = 'completed',
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed:
                                              () => setState(
                                                () => tasks.remove(t),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditTask(),
        child: Icon(Icons.add),
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
      descController.text = widget.task!.description;
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: descController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          SizedBox(height: 10),
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
                icon: Icon(Icons.calendar_today),
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
                    () =>
                        deadline = DateTime(
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
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || deadline == null) return;
              Navigator.pop(
                context,
                Task(
                  id: widget.task?.id ?? Uuid().v4(),
                  title: titleController.text,
                  description: descController.text,
                  deadline: deadline!,
                  status: 'pending',
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Modified main.dart to handle loading states better
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:todo_app/core/provider/auth_provider.dart';
// import 'package:todo_app/core/provider/task_provider.dart';
// import 'package:todo_app/data/services/auth_services.dart';
// import 'package:todo_app/data/services/pocketbase_services.dart';
// import 'package:todo_app/presentations/view/auth/login_screen.dart';
// import 'package:todo_app/presentations/view/home_page.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize timezone
//   tz.initializeTimeZones();

//   // Initialize notifications
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   const DarwinInitializationSettings initializationSettingsIOS =
//       DarwinInitializationSettings();

//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: initializationSettingsIOS,
//   );

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//   // Initialize PocketBase service with error handling
//   try {
//     await PocketBaseService.initialize();
//   } catch (e) {
//     print('Failed to initialize PocketBase: $e');
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => TaskProvider()),
//       ],
//       child: MaterialApp(
//         title: 'Deadline Todo App',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           useMaterial3: true,
//           brightness: Brightness.light,
//         ),
//         darkTheme: ThemeData(
//           primarySwatch: Colors.blue,
//           useMaterial3: true,
//           brightness: Brightness.dark,
//         ),
//         themeMode: ThemeMode.system,
//         home: const AuthCheckScreen(),
//       ),
//     );
//   }
// }

// class AuthCheckScreen extends StatefulWidget {
//   const AuthCheckScreen({super.key});

//   @override
//   State<AuthCheckScreen> createState() => _AuthCheckScreenState();
// }

// class _AuthCheckScreenState extends State<AuthCheckScreen> {
//   bool _isChecking = true;
//   bool _isRetrying = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkAuth();
//   }

//   Future<void> _checkAuth() async {
//     if (mounted) {
//       setState(() {
//         _isChecking = true;
//       });
//     }

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.checkUserLoggedIn();

//     if (mounted) {
//       setState(() {
//         _isChecking = false;
//         _isRetrying = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, _) {
//         // Show loading state
//         if (_isChecking) {
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircularProgressIndicator(),
//                   const SizedBox(height: 20),
//                   Text(
//                     _isRetrying
//                         ? 'Retrying connection...'
//                         : 'Checking authentication...',
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Show error state if needed
//         if (authProvider.status == AuthStatus.error) {
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, color: Colors.red, size: 48),
//                   const SizedBox(height: 16),
//                   Text(
//                     authProvider.errorMessage ?? 'An error occurred',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _isRetrying = true;
//                       });
//                       _checkAuth();
//                     },
//                     child: const Text('Retry'),
//                   ),
//                   const SizedBox(height: 12),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const LoginPage(),
//                         ),
//                       );
//                     },
//                     child: const Text('Go to Login'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // User is authenticated
//         if (authProvider.status == AuthStatus.authenticated) {
//           // Initialize tasks
//           Future.microtask(() {
//             Provider.of<TaskProvider>(context, listen: false).initTasks();
//           });
//           return const HomePage();
//         }

//         // User is not authenticated
//         return const LoginPage();
//       },
//     );
//   }
// }
