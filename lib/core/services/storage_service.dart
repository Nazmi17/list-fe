import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../models/user.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(StorageKeys.token, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(StorageKeys.token);
  }

  Future<void> saveUserInfo(User user) async {
    await _prefs.setInt(StorageKeys.userId, user.id);
    await _prefs.setString(StorageKeys.userEmail, user.email);
    await _prefs.setString(StorageKeys.userName, user.username);
  }

  Future<User?> getUserInfo() async {
    final userId = _prefs.getInt(StorageKeys.userId);
    final email = _prefs.getString(StorageKeys.userEmail);
    final username = _prefs.getString(StorageKeys.userName);

    if (userId == null || email == null || username == null) {
      return null;
    }

    return User(
      id: userId,
      email: email,
      username: username,
      createdAt: DateTime.now(), 
      updatedAt: DateTime.now(), 
    );
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
