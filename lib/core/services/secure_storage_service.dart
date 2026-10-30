import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.authToken, token);
    } catch (_) {}
    try {
      await _storage.write(key: StorageKeys.authToken, value: token);
    } catch (_) {}
  }

  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      if (token != null && token.trim().isNotEmpty) {
        return token.trim();
      }
    } catch (_) {}

    try {
      final token = await _storage.read(key: StorageKeys.authToken).timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );
      if (token != null && token.trim().isNotEmpty) {
        return token.trim();
      }
    } catch (_) {}

    return null;
  }

  Future<void> deleteAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.authToken);
    } catch (_) {}
    try {
      await _storage.delete(key: StorageKeys.authToken);
    } catch (_) {}
  }

  Future<void> saveUserData(String userDataJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userData, userDataJson);
    } catch (_) {}
    try {
      await _storage.write(key: StorageKeys.userData, value: userDataJson);
    } catch (_) {}
  }

  Future<String?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(StorageKeys.userData);
      if (data != null && data.trim().isNotEmpty) {
        return data.trim();
      }
    } catch (_) {}

    try {
      final data = await _storage.read(key: StorageKeys.userData).timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );
      if (data != null && data.trim().isNotEmpty) {
        return data.trim();
      }
    } catch (_) {}

    return null;
  }

  Future<void> deleteUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.userData);
    } catch (_) {}
    try {
      await _storage.delete(key: StorageKeys.userData);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.authToken);
      await prefs.remove(StorageKeys.userData);
    } catch (_) {}
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
