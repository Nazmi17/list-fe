import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/providers/folder_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/task.dart';
import '../../../../core/routes/routes.dart';
import '../widgets/task_card_widget.dart'; 
import '../widgets/empty_task_widget.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  List<DateTime> _getDates() {
    final today = DateTime.now();
    return List.generate(5, (index) => today.add(Duration(days: index - 2)));
  }

  String _getMonthName(DateTime date) {
    return DateFormat('MMM').format(date);
  }

  String _getDayName(DateTime date) {
    return DateFormat('E').format(date);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    switch (_selectedFilter) {
      case 'Share':
        return tasks.where((task) => task.folderId != null).toList();
      case 'In Progress':
        return tasks.where((task) => !task.complete).toList();
      case 'Completed':
        return tasks.where((task) => task.complete).toList();
      default:
        return tasks;
    }
  }

Future<void> _showLogoutDialog(
  BuildContext context,
  AuthProvider authProvider,
) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1D1D1D),
      title: const Text('Logout', style: TextStyle(color: Colors.white)),
      content: const Text(
        'Are you sure you want to logout?',
        style: TextStyle(color: Colors.grey),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (shouldLogout == true) {
    await authProvider.logout();

    if (context.mounted) {
      context.read<TaskProvider>().clearState();
      context.read<FolderProvider>().clearState();

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}
  Future<void> _confirmDeleteTask(int taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1D1D),
        title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<TaskProvider>().deleteTask(taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final filteredTasks = _getFilteredTasks(taskProvider.tasks);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 110,
            color: const Color.fromARGB(255, 0, 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getDates().length,
              itemBuilder: (context, index) {
                final date = _getDates()[index];
                final isSelected = _isSameDay(date, _selectedDate);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Center(
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8BE4A9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8BE4A9)
                              : Colors.grey[800]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getMonthName(date),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getDayName(date),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Share', 'In Progress', 'Completed'].map((
                  filter,
                ) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8BE4A9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8BE4A9)
                              : Colors.grey[700]!,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: taskProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8875FF)),
                  )
                : filteredTasks.isEmpty
                ? const EmptyTaskWidget()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return TaskCardWidget(
                        task: task,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.editTask,
                            arguments: task,
                          );
                        },
                        onToggleComplete: () async {
                          if (!task.complete) {
                            final success = await taskProvider
                                .toggleTaskComplete(task.id);

                            if (success &&
                                _selectedFilter == 'In Progress' &&
                                mounted) {
                              setState(() {
                                _selectedFilter = 'All';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Task completed! Switched to All filter.',
                                  ),
                                ),
                              );
                            }
                          } else {
                            await taskProvider.toggleTaskComplete(task.id);
                          }
                        },
                        onDelete: () => _confirmDeleteTask(task.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
