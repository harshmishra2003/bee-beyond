import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: StorageKeys.authToken, value: token);
    } catch (_) {}
  }

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: StorageKeys.authToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: StorageKeys.authToken);
    } catch (_) {}
  }

  Future<void> saveUserData(String userDataJson) async {
    try {
      await _storage.write(key: StorageKeys.userData, value: userDataJson);
    } catch (_) {}
  }

  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: StorageKeys.userData);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: StorageKeys.userData);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
