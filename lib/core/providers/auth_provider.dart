import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthProvider({required AuthService authService}) : _authService = authService;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _authService.initializeAuth();
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }

    _isInitialized = true;
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.register(
        email: email,
        username: username,
        password: password,
      );

      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _currentUser = authResponse.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
