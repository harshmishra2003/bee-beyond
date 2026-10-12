import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({required this.remoteDataSource, required this.secureStorage});

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    await secureStorage.saveAuthToken('sample_jwt_token_${user.id}');
    return user;
  }

  @override
  Future<UserEntity> register(String name, String email, String phone, String password) async {
    final user = await remoteDataSource.register(name, email, phone, password);
    await secureStorage.saveAuthToken('sample_jwt_token_${user.id}');
    return user;
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    return await remoteDataSource.verifyOtp(phone, otp);
  }

  @override
  Future<void> logout() async {
    await secureStorage.deleteAuthToken();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await secureStorage.getAuthToken();
    if (token == null) return null;
    return const UserEntity(
      id: 'u_101',
      name: 'Aarav Sharma',
      email: 'aarav@example.com',
      phone: '+91 9876543210',
      studentId: 'BEYOND-2025-884',
    );
  }
}
