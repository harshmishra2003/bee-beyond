import 'package:dio/dio.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleException(dynamic exception) {
    if (exception is DioException) {
      switch (exception.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutFailure('Connection timed out. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = exception.response?.statusCode;
          final msg = exception.response?.data?['message'] ?? 
                      exception.response?.data?['error'] ?? 
                      'Server error ($statusCode)';
          
          if (statusCode == 401 || statusCode == 403) {
            return AuthFailure(msg);
          } else if (statusCode == 404) {
            return NotFoundFailure(msg);
          } else if (statusCode == 409) {
            return ConflictFailure(msg);
          } else if (statusCode == 422) {
            return ValidationFailure(msg);
          }
          return ServerFailure(msg, statusCode: statusCode);
        case DioExceptionType.cancel:
          return const ServerFailure('Request cancelled.');
        case DioExceptionType.connectionError:
          return const NetworkFailure('No internet connection. Please check your network.');
        default:
          return ServerFailure(exception.message ?? 'Unexpected network error occurred.');
      }
    } else if (exception is Failure) {
      return exception;
    } else {
      return ServerFailure(exception.toString());
    }
  }
}
