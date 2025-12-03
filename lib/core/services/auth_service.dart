import '../constants/api_constants.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  Future<User> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        body: {'email': email, 'username': username, 'password': password},
        includeAuth: false,
      );

      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        body: {'email': email, 'password': password},
        includeAuth: false,
      );

      final authResponse = AuthResponse.fromJson(response);

      await _storageService.saveToken(authResponse.token);
      await _storageService.saveUserInfo(authResponse.user);

      _apiService.setToken(authResponse.token);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _apiService.setToken(null);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    if (token != null) {
      _apiService.setToken(token);
      return true;
    }
    return false;
  }

  Future<User?> getCurrentUser() async {
    return await _storageService.getUserInfo();
  }

  //call on app start
  Future<void> initializeAuth() async {
    final token = await _storageService.getToken();
    if (token != null) {
      _apiService.setToken(token);
    }
  }
}
