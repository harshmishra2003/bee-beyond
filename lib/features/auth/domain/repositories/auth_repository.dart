import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String name, String email, String phone, String password);
  Future<bool> verifyOtp(String phone, String otp);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
