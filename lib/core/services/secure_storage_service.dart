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
    await _storage.write(key: StorageKeys.authToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: StorageKeys.authToken);
  }

  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: StorageKeys.userData, value: userDataJson);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: StorageKeys.userData);
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: StorageKeys.userData);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
