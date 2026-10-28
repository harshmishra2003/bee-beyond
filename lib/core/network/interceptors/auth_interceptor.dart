import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final VoidCallback? onUnauthorized;

  AuthInterceptor(this._secureStorage, {this.onUnauthorized});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path.toLowerCase();
    // Only trigger onUnauthorized logout if the path is explicitly an auth/user profile verification route
    if (err.response?.statusCode == 401 && (path.contains('/user/profile') || path.contains('/auth/verify'))) {
      onUnauthorized?.call();
    }
    return super.onError(err, handler);
  }
}
