import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/folder_provider.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/routes/routes.dart';
import '../widgets/dashboard_stat_widget.dart';
import '../widgets/folder_card_widget.dart';

class FolderListPage extends StatefulWidget {
  const FolderListPage({super.key});

  @override
  State<FolderListPage> createState() => _FolderListPageState();
}

class _FolderListPageState extends State<FolderListPage> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<FolderProvider>().fetchFolders();

      if (mounted) {
        context.read<TaskProvider>().fetchTasks();
      }
    });
  }

  int _getTaskCountForFolder(int folderId) {
    final tasks = context.read<TaskProvider>().tasks;
    return tasks.where((task) => task.folderId == folderId).length;
  }

  int _getCompletionPercentage(int folderId) {
    final tasks = context.read<TaskProvider>().tasks;
    final folderTasks = tasks
        .where((task) => task.folderId == folderId)
        .toList();

    if (folderTasks.isEmpty) return 0;

    final completedTasks = folderTasks.where((task) => task.complete).length;
    return ((completedTasks / folderTasks.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final folderProvider = context.watch<FolderProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final totalFolders = folderProvider.allFolders.length;
    final totalTasks = taskProvider.tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        authProvider.currentUser?.username ?? 'User',
                        style: const TextStyle(
                          color: Color(0xFF8BE4A9),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: DashboardStatWidget(
                      icon: Icons.folder,
                      label: 'Your Total Folders',
                      count: totalFolders,
                      badge: '+${totalFolders > 0 ? totalFolders : 0}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardStatWidget(
                      icon: Icons.checklist,
                      label: 'Your Total Task',
                      count: totalTasks,
                      badge: '+${totalTasks > 0 ? totalTasks : 0}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: folderProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8875FF),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (folderProvider.ownFolders.isNotEmpty) ...[
                            const Text(
                              'Your Folders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...folderProvider.ownFolders.map((folder) {
                              final taskCount = _getTaskCountForFolder(
                                folder.id,
                              );
                              final completion = _getCompletionPercentage(
                                folder.id,
                              );
                              return FolderCardWidget(
                                folder: folder,
                                taskCount: taskCount,
                                completionPercentage: completion,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.folderDetail,
                                    arguments: folder,
                                  );
                                },
                              );
                            }).toList(),
                            const SizedBox(height: 24),
                          ],

                          if (folderProvider.sharedFolders.isNotEmpty) ...[
                            const Text(
                              'Shared Folders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...folderProvider.sharedFolders.map((folder) {
                              final taskCount = _getTaskCountForFolder(
                                folder.id,
                              );
                              final completion = _getCompletionPercentage(
                                folder.id,
                              );
                              return FolderCardWidget(
                                folder: folder,
                                taskCount: taskCount,
                                completionPercentage: completion,
                                isShared: true,
                                ownerName: folder.user?.username ?? 'Unknown',
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.folderDetail,
                                    arguments: folder,
                                  );
                                },
                              );
                            }).toList(),
                          ],

                          if (folderProvider.ownFolders.isEmpty &&
                              folderProvider.sharedFolders.isEmpty)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Image.asset(
                                    'assets/images/bro2.png',
                                    width: 200,
                                    height: 200,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.folder_outlined,
                                        size: 100,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "You don't have any folder yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
