import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? dob,
    String? gender,
  });
  Future<bool> verifyOtp(String phone, String otp);
  Future<void> forgotPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login(String email, String password) async {
    // The PHP backend expects standard JSON format
    final response = await dioClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data['status'] == 'success' || data['success'] == true || data['status'] == true || data['user'] != null) {
        final userData = data['user'] ?? data['data'] ?? data;
        return UserModel.fromJson(userData);
      } else {
        throw ServerFailure(data['message'] ?? 'Login failed');
      }
    } else {
      throw ServerFailure('Failed to connect to the server');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? dob,
    String? gender,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        if (dob != null && dob.isNotEmpty) 'dob': dob,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data['status'] == 'success' || data['success'] == true || data['status'] == true || data['user'] != null) {
        final userData = data['user'] ?? data['data'] ?? data;
        return UserModel.fromJson(userData);
      } else {
        throw ServerFailure(data['message'] ?? 'Registration failed');
      }
    } else {
      throw ServerFailure('Failed to connect to the server');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response = await dioClient.post(
      ApiEndpoints.forgotPassword,
      data: {
        'email': email,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data['status'] == 'success' || data['success'] == true || data['status'] == true) {
        return; // Success
      } else {
        throw ServerFailure(data['message'] ?? 'Failed to send reset link');
      }
    } else {
      throw ServerFailure('Failed to connect to the server');
    }
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    final response = await dioClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'phone': phone,
        'otp': otp,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      return data['status'] == 'success' || data['success'] == true;
    }
    return false;
  }
}
