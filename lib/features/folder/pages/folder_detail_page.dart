// lib/features/folder/pages/folder_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/folder.dart';
import '../../../../core/models/task.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/folder_provider.dart';
import '../../../../core/providers/task_provider.dart';
import '../../task/widgets/task_card_widget.dart';
import '../../../core/routes/routes.dart';

class FolderDetailPage extends StatefulWidget {
  final Folder folder;

  const FolderDetailPage({super.key, required this.folder});

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  Future<void> _confirmDeleteFolder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1D1D),
        title: const Text(
          'Delete Folder',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure? All tasks inside will be deleted.',
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
      final success = await context.read<FolderProvider>().deleteFolder(
        widget.folder.id,
      );

      if (success && mounted) {
        Navigator.pop(context); 
      }
    }
  }

  Future<void> _confirmLeaveFolder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1D1D),
        title: const Text(
          'Leave Folder',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to remove this shared folder from your list?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<FolderProvider>().leaveSharedFolder(
        widget.folder.id,
      );

      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        final error = context.read<FolderProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to leave folder')),
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
          'Remove this task?',
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
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final isOwner = authProvider.currentUser?.id == widget.folder.userId;

    final folderTasks = taskProvider.tasks
        .where((t) => t.folderId == widget.folder.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(
        0xFF121212,
      ), 
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          isOwner ? 'Your Folder' : 'Shared Folder',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text Putih
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.folder.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        if (!isOwner) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 14,
                                color: Color(0xFF8875FF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Owner: ${widget.folder.user?.username ?? "Unknown"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8875FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (isOwner) ...[
                    GestureDetector(
                      onTap: _confirmDeleteFolder,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Manage members coming soon!'),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: _confirmLeaveFolder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Remove this folder\nfrom my list',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Task(s) List:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: folderTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 60,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks in this folder',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: folderTasks.length,
                      itemBuilder: (context, index) {
                        final task = folderTasks[index];

                        return TaskCardWidget(
                          task: task,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.editTask,
                              arguments:
                                  task, 
                            );
                          },
                          onToggleComplete: () {
                            context.read<TaskProvider>().toggleTaskComplete(
                              task.id,
                            );
                          },
                          onDelete: () {
                            _confirmDeleteTask(task.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
