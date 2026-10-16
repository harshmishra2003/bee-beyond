import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? dob,
    String? gender,
  });
  Future<bool> verifyOtp(String phone, String otp);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
