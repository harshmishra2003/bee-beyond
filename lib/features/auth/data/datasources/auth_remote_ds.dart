import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:bee_beeyond/core/network/dio_client.dart';
import 'package:bee_beeyond/core/constants/api_endpoints.dart';
import 'package:bee_beeyond/core/errors/failures.dart';
import 'package:bee_beeyond/core/services/secure_storage_service.dart';
import 'package:bee_beeyond/features/auth/data/models/user_model.dart';

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
  final SecureStorageService secureStorage;

  AuthRemoteDataSourceImpl(this.dioClient, this.secureStorage);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
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

      final rawData = response.data;
      final Map<String, dynamic> data = rawData is String
          ? jsonDecode(rawData)
          : Map<String, dynamic>.from(rawData);

      final isSuccess = data['success'] == true || data['status'] == 'success' || data['status'] == true;

      if (isSuccess && data['data'] != null) {
        final payload = Map<String, dynamic>.from(data['data']);
        final userData = payload['user'] ?? payload;
        final token = payload['token'] ?? data['token'];

        if (token != null && token.toString().trim().isNotEmpty) {
          await secureStorage.saveAuthToken(token.toString().trim());
        }

        return UserModel.fromJson(Map<String, dynamic>.from(userData));
      } else {
        throw AuthFailure(data['message']?.toString() ?? 'Login failed.');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final rawData = e.response!.data;
        final Map<String, dynamic> data = rawData is String
            ? jsonDecode(rawData)
            : Map<String, dynamic>.from(rawData);
        final message = data['message']?.toString() ?? 'Invalid email or password.';
        throw AuthFailure(message);
      }
      rethrow;
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
    try {
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

      final rawData = response.data;
      final Map<String, dynamic> data = rawData is String
          ? jsonDecode(rawData)
          : Map<String, dynamic>.from(rawData);

      final isSuccess = data['success'] == true || data['status'] == 'success' || data['status'] == true;

      if (isSuccess && data['data'] != null) {
        final payload = Map<String, dynamic>.from(data['data']);
        final userData = payload['user'] ?? payload;
        final token = payload['token'] ?? data['token'];

        if (token != null && token.toString().trim().isNotEmpty) {
          await secureStorage.saveAuthToken(token.toString().trim());
        }

        return UserModel.fromJson(Map<String, dynamic>.from(userData));
      } else {
        throw AuthFailure(data['message']?.toString() ?? 'Registration failed.');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final rawData = e.response!.data;
        final Map<String, dynamic> data = rawData is String
            ? jsonDecode(rawData)
            : Map<String, dynamic>.from(rawData);
        final message = data['message']?.toString() ?? 'Registration failed.';
        throw AuthFailure(message);
      }
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
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

      final rawData = response.data;
      final Map<String, dynamic> data = rawData is String
          ? jsonDecode(rawData)
          : Map<String, dynamic>.from(rawData);

      if (data['success'] == true || data['status'] == 'success' || data['status'] == true) {
        return;
      } else {
        throw AuthFailure(data['message']?.toString() ?? 'Failed to send reset link');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final rawData = e.response!.data;
        final Map<String, dynamic> data = rawData is String
            ? jsonDecode(rawData)
            : Map<String, dynamic>.from(rawData);
        throw AuthFailure(data['message']?.toString() ?? 'Failed to send reset link.');
      }
      rethrow;
    }
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    try {
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

      final rawData = response.data;
      final Map<String, dynamic> data = rawData is String
          ? jsonDecode(rawData)
          : Map<String, dynamic>.from(rawData);

      return data['success'] == true || data['status'] == 'success';
    } catch (_) {
      return false;
    }
  }
}
