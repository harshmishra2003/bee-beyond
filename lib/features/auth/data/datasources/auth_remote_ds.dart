import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String phone, String password);
  Future<bool> verifyOtp(String phone, String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login(String email, String password) async {
    // Mock response or network call
    await Future.delayed(const Duration(milliseconds: 800));
    return UserModel(
      id: 'u_101',
      name: 'Aarav Sharma',
      email: email,
      phone: '+91 9876543210',
      studentId: 'BEYOND-2025-884',
    );
  }

  @override
  Future<UserModel> register(String name, String email, String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return UserModel(
      id: 'u_102',
      name: name,
      email: email,
      phone: phone,
      studentId: 'BEYOND-2025-999',
    );
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return otp == '1234';
  }
}
