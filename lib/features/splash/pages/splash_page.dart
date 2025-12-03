import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/routes/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = context.read<AuthProvider>();

    await authProvider.initialize();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_logo',
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
                cacheWidth: 240, 
                cacheHeight: 240,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8875FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'UpTodo',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8BE4A9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
