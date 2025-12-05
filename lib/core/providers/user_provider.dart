import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;

  bool _isLoading = false;
  String? _errorMessage;
  List<User> _searchResults = [];

  UserProvider({required UserService userService}) : _userService = userService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<User> get searchResults => _searchResults;

  Future<bool> updateUser({
    required int userId,
    String? email,
    String? username,
    String? password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _userService.updateUser(
        userId: userId,
        email: email,
        username: username,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _userService.deleteUser(userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await _userService.searchUsers(query);
      _searchResults = results;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearState() {
    _searchResults = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
