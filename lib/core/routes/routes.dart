import 'package:flutter/material.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/home/pages/main_navigation_page.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/task/pages/add_task_page.dart';
import '../../features/folder/pages/add_folder_page.dart';
import '../../features/folder/pages/folder_detail_page.dart'; 
import '../../core/models/folder.dart'; 
import '../../core/models/task.dart'; 
import '../../features/task/pages/edit_task_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addTask = '/add-task';
  static const String addFolder = '/add-folder';
  static const String folderDetail = '/folder-detail'; 
  static const String editTask = '/edit-task';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationPage());
      case addTask:
        return MaterialPageRoute(builder: (_) => const AddTaskPage());
      case addFolder:
        return MaterialPageRoute(builder: (_) => const AddFolderPage());
      case folderDetail:
        final folder = settings.arguments as Folder;
        return MaterialPageRoute(
          builder: (_) => FolderDetailPage(folder: folder),
        );
      case editTask:
        final task = settings.arguments as Task;
        return MaterialPageRoute(
          builder: (_) =>
              EditTaskPage(task: task),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
