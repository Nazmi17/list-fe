import '../constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService({required ApiService apiService}) : _apiService = apiService;
  
  Future<User> updateUser({
    required int userId,
    String? email,
    String? username,
    String? password,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (email != null) body['email'] = email;
      if (username != null) body['username'] = username;
      if (password != null) body['password'] = password;

      final response = await _apiService.patch(
        ApiConstants.user(userId),
        body: body,
      );

      return User.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _apiService.delete(ApiConstants.user(userId));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiService.get(
        ApiConstants.searchUsers,
        queryParams: {'query': query},
      );

      return (response as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
