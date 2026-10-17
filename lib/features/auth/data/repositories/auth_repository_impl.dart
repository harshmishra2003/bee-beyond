import 'dart:convert';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({required this.remoteDataSource, required this.secureStorage});

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    
    // Save the User data locally for instant UI access across sessions
    await secureStorage.saveUserData(jsonEncode(user.toJson()));
    
    return user;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? dob,
    String? gender,
  }) async {
    final user = await remoteDataSource.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      dob: dob,
      gender: gender,
    );
    
    // Save the User data locally for instant UI access across sessions
    await secureStorage.saveUserData(jsonEncode(user.toJson()));
    
    return user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    return await remoteDataSource.verifyOtp(phone, otp);
  }

  @override
  Future<void> logout() async {
    try {
      await secureStorage.deleteAuthToken();
      await secureStorage.deleteUserData();
      await secureStorage.clearAll();
    } catch (_) {
      // Safely ignore storage errors during sign out
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await secureStorage.getAuthToken();
    if (token == null) return null;
    
    final userDataJson = await secureStorage.getUserData();
    if (userDataJson != null) {
      try {
        final decodedData = jsonDecode(userDataJson);
        return UserModel.fromJson(decodedData);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }
}
