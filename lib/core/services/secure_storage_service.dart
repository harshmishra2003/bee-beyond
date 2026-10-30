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
      await _storage.write(key: StorageKeys.authToken, value: token);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.authToken, token);
    } catch (_) {}
  }

  Future<String?> getAuthToken() async {
    String? token;
    try {
      token = await _storage.read(key: StorageKeys.authToken).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } catch (_) {}

    if (token != null && token.isNotEmpty) {
      return token;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageKeys.authToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: StorageKeys.authToken);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.authToken);
    } catch (_) {}
  }

  Future<void> saveUserData(String userDataJson) async {
    try {
      await _storage.write(key: StorageKeys.userData, value: userDataJson);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userData, userDataJson);
    } catch (_) {}
  }

  Future<String?> getUserData() async {
    String? data;
    try {
      data = await _storage.read(key: StorageKeys.userData).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } catch (_) {}

    if (data != null && data.isNotEmpty) {
      return data;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageKeys.userData);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: StorageKeys.userData);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.userData);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.authToken);
      await prefs.remove(StorageKeys.userData);
    } catch (_) {}
  }
}
