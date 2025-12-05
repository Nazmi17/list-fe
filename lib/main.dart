import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/routes.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/folder_service.dart';
import 'core/services/task_service.dart';
import 'core/services/user_service.dart'; 
import 'core/providers/auth_provider.dart';
import 'core/providers/folder_provider.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final apiService = ApiService();

  final authService = AuthService(
    apiService: apiService,
    storageService: storageService,
  );
  final folderService = FolderService(apiService: apiService);
  final taskService = TaskService(apiService: apiService);

  runApp(
    MainApp(
      apiService: apiService,
      authService: authService,
      folderService: folderService,
      taskService: taskService,
    ),
  );
}

class MainApp extends StatelessWidget {
  final ApiService apiService;
  final AuthService authService;
  final FolderService folderService;
  final TaskService taskService;

  const MainApp({
    super.key,
    required this.apiService,
    required this.authService,
    required this.folderService,
    required this.taskService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider untuk ApiService (agar bisa diakses oleh UserService di bawah)
        Provider<ApiService>(create: (_) => apiService),

        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => FolderProvider(folderService: folderService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskService: taskService),
        ),

        // --- USER PROVIDER ---
        ChangeNotifierProvider(
          create: (context) => UserProvider(
            // Kita menggunakan context.read<ApiService>() karena ApiService sudah disediakan di atas
            userService: UserService(apiService: context.read<ApiService>()),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
          primaryColor: const Color(0xFF8875FF),
          scaffoldBackgroundColor: const Color.fromARGB(255, 162, 160, 160),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF8875FF),
            secondary: Color(0xFF8875FF),
            surface: Color(0xFF1D1D1D),
            background: Color(0xFF121212),
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
