import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/workshop_item.dart';
import '../../domain/entities/workshop_order_response_entity.dart';
import '../../domain/entities/workshop_verify_payment_response_entity.dart';

abstract class WorkshopRemoteDataSource {
  Future<List<WorkshopItem>> getWorkshops();
  Future<WorkshopItem?> getWorkshopDetail(String id);
  Future<WorkshopOrderResponseEntity> createWorkshopOrder({
    required int workshopId,
    required String attendeeName,
    required String attendeeEmail,
    required String attendeePhone,
    String? specialNote,
  });
  Future<WorkshopVerifyPaymentResponseEntity> verifyWorkshopPayment({
    required int workshopOrderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });
  Future<WorkshopVerifyPaymentResponseEntity> getWorkshopOrderStatus({
    required int workshopOrderId,
  });
}

class WorkshopRemoteDataSourceImpl implements WorkshopRemoteDataSource {
  final DioClient? _dioClient;

  WorkshopRemoteDataSourceImpl([this._dioClient]);

  @override
  Future<List<WorkshopItem>> getWorkshops() async {
    if (_dioClient == null) {
      return [];
    }

    try {
      final response = await _dioClient.get(
        ApiEndpoints.workshops,
        options: Options(validateStatus: (status) => true),
      );

      final statusCode = response.statusCode ?? 500;
      if (statusCode >= 200 && statusCode < 300 && response.data != null) {
        dynamic rawData = response.data;
        if (rawData is String) {
          rawData = jsonDecode(rawData);
        }

        final List list = rawData is List
            ? rawData
            : (rawData is Map
                ? (rawData['data'] ?? rawData['workshops'] ?? rawData['items'] ?? [])
                : []);

        return list
            .map((json) => WorkshopItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Swallowed error fallback to empty list
    }

    return [];
  }

  @override
  Future<WorkshopItem?> getWorkshopDetail(String id) async {
    if (_dioClient != null) {
      try {
        final response = await _dioClient.get(
          ApiEndpoints.workshopDetail,
          queryParameters: {
            'id': id,
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
          options: Options(validateStatus: (status) => true),
        );

        final statusCode = response.statusCode ?? 500;
        if (statusCode >= 200 && statusCode < 300 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) rawData = jsonDecode(rawData);

          final Map<String, dynamic> data = rawData is Map
              ? (rawData['data'] is Map ? rawData['data'] : rawData)
              : {};

          if (data.isNotEmpty && (data['id'] != null || data['title'] != null)) {
            return WorkshopItem.fromJson(data);
          }
        }
      } catch (_) {}
    }

    // Fallback: search in getWorkshops() list fetched from dynamic API
    final list = await getWorkshops();
    try {
      final cleanId = id.trim().toLowerCase();
      return list.firstWhere(
        (w) => w.id.trim().toLowerCase() == cleanId || w.id.toString() == id.toString(),
      );
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }

  @override
  Future<WorkshopOrderResponseEntity> createWorkshopOrder({
    required int workshopId,
    required String attendeeName,
    required String attendeeEmail,
    required String attendeePhone,
    String? specialNote,
  }) async {
    final client = _dioClient;
    if (client == null) {
      return const WorkshopOrderResponseEntity(
        success: false,
        message: 'Network client not available.',
        workshopOrderId: 0,
        registrationId: 0,
        bookingNumber: '',
        amount: 0,
        currency: 'INR',
        razorpayOrderId: '',
        razorpayKeyId: '',
      );
    }

    try {
      final response = await client.post(
        ApiEndpoints.workshopCreateOrder,
        data: {
          'workshop_id': workshopId,
          'attendee_name': attendeeName,
          'attendee_email': attendeeEmail,
          'attendee_phone': attendeePhone,
          'special_note': specialNote ?? '',
        },
        options: Options(validateStatus: (status) => true),
      );

      if (response.data != null) {
        dynamic rawData = response.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }

        Map<String, dynamic>? dataMap;
        if (rawData is Map<String, dynamic>) {
          dataMap = rawData;
        } else if (rawData is Map) {
          dataMap = Map<String, dynamic>.from(rawData);
        }

        if (dataMap != null) {
          final entity = WorkshopOrderResponseEntity.fromJson(dataMap);
          final statusCode = response.statusCode ?? 500;
          final bool isSuccessStatus = statusCode >= 200 && statusCode < 300;

          if (!isSuccessStatus) {
            final msg = entity.message.isNotEmpty
                ? entity.message
                : 'Server error (HTTP $statusCode)';
            return WorkshopOrderResponseEntity(
              success: false,
              message: msg,
              workshopOrderId: entity.workshopOrderId,
              registrationId: entity.registrationId,
              bookingNumber: entity.bookingNumber,
              amount: entity.amount,
              currency: entity.currency,
              razorpayOrderId: entity.razorpayOrderId,
              razorpayKeyId: entity.razorpayKeyId,
            );
          }
          return entity;
        }
      }

      return WorkshopOrderResponseEntity(
        success: false,
        message: 'Server responded with status ${response.statusCode}',
        workshopOrderId: 0,
        registrationId: 0,
        bookingNumber: '',
        amount: 0,
        currency: 'INR',
        razorpayOrderId: '',
        razorpayKeyId: '',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        dynamic rawData = e.response!.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }
        final message = (rawData is Map && rawData['message'] != null)
            ? rawData['message'].toString()
            : 'Failed to create workshop order (HTTP ${e.response?.statusCode})';

        return WorkshopOrderResponseEntity(
          success: false,
          message: message,
          workshopOrderId: 0,
          registrationId: 0,
          bookingNumber: '',
          amount: 0,
          currency: 'INR',
          razorpayOrderId: '',
          razorpayKeyId: '',
        );
      }
      return WorkshopOrderResponseEntity(
        success: false,
        message: 'Network error while creating order: ${e.message ?? e.toString()}',
        workshopOrderId: 0,
        registrationId: 0,
        bookingNumber: '',
        amount: 0,
        currency: 'INR',
        razorpayOrderId: '',
        razorpayKeyId: '',
      );
    } catch (e) {
      return WorkshopOrderResponseEntity(
        success: false,
        message: 'Failed to create workshop order: ${e.toString()}',
        workshopOrderId: 0,
        registrationId: 0,
        bookingNumber: '',
        amount: 0,
        currency: 'INR',
        razorpayOrderId: '',
        razorpayKeyId: '',
      );
    }
  }

  @override
  Future<WorkshopVerifyPaymentResponseEntity> verifyWorkshopPayment({
    required int workshopOrderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final client = _dioClient;
    if (client == null) {
      return WorkshopVerifyPaymentResponseEntity.networkError('Network client not available.');
    }

    try {
      final response = await client.post(
        ApiEndpoints.workshopVerifyPayment,
        data: {
          'workshop_order_id': workshopOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature,
        },
        options: Options(validateStatus: (status) => true),
      );

      if (response.data != null) {
        dynamic rawData = response.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }

        Map<String, dynamic>? dataMap;
        if (rawData is Map<String, dynamic>) {
          dataMap = rawData;
        } else if (rawData is Map) {
          dataMap = Map<String, dynamic>.from(rawData);
        }

        if (dataMap != null) {
          final entity = WorkshopVerifyPaymentResponseEntity.fromJson(dataMap);
          final statusCode = response.statusCode ?? 500;
          final bool isSuccessStatus = statusCode >= 200 && statusCode < 300;

          if (!isSuccessStatus) {
            final msg = entity.message.isNotEmpty
                ? entity.message
                : 'Server error (HTTP $statusCode)';
            return WorkshopVerifyPaymentResponseEntity(
              success: false,
              registrationStatus: entity.registrationStatus.isNotEmpty ? entity.registrationStatus : 'failed',
              bookingNumber: entity.bookingNumber,
              message: msg,
              isNetworkError: false,
            );
          }
          return entity;
        }
      }

      final statusCode = response.statusCode ?? 500;
      return WorkshopVerifyPaymentResponseEntity(
        success: false,
        registrationStatus: 'failed',
        bookingNumber: '',
        message: 'Server error (HTTP $statusCode)',
        isNetworkError: false,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        dynamic rawData = e.response!.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }
        final message = (rawData is Map && rawData['message'] != null)
            ? rawData['message'].toString()
            : 'Payment verification failed (HTTP ${e.response?.statusCode})';

        return WorkshopVerifyPaymentResponseEntity(
          success: false,
          registrationStatus: 'failed',
          bookingNumber: '',
          message: message,
          isNetworkError: false,
        );
      }
      return WorkshopVerifyPaymentResponseEntity.networkError(
        'Network error during payment verification: ${e.message ?? e.toString()}',
      );
    } catch (e) {
      return WorkshopVerifyPaymentResponseEntity(
        success: false,
        registrationStatus: 'failed',
        bookingNumber: '',
        message: 'Unexpected parsing or response processing error: ${e.toString()}',
        isNetworkError: false,
      );
    }
  }

  @override
  Future<WorkshopVerifyPaymentResponseEntity> getWorkshopOrderStatus({
    required int workshopOrderId,
  }) async {
    final client = _dioClient;
    if (client == null) {
      return WorkshopVerifyPaymentResponseEntity.networkError('Network client not available.');
    }

    try {
      final response = await client.post(
        ApiEndpoints.workshopOrderStatus,
        data: {
          'workshop_order_id': workshopOrderId,
        },
        options: Options(validateStatus: (status) => true),
      );

      if (response.data != null) {
        dynamic rawData = response.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }

        Map<String, dynamic>? dataMap;
        if (rawData is Map<String, dynamic>) {
          dataMap = rawData;
        } else if (rawData is Map) {
          dataMap = Map<String, dynamic>.from(rawData);
        }

        if (dataMap != null) {
          final entity = WorkshopVerifyPaymentResponseEntity.fromJson(dataMap);
          final statusCode = response.statusCode ?? 500;
          final bool isSuccessStatus = statusCode >= 200 && statusCode < 300;

          if (!isSuccessStatus) {
            final msg = entity.message.isNotEmpty
                ? entity.message
                : 'Server error (HTTP $statusCode)';
            return WorkshopVerifyPaymentResponseEntity(
              success: false,
              registrationStatus: entity.registrationStatus.isNotEmpty ? entity.registrationStatus : 'failed',
              bookingNumber: entity.bookingNumber,
              message: msg,
              isNetworkError: false,
            );
          }
          return entity;
        }
      }

      final statusCode = response.statusCode ?? 500;
      return WorkshopVerifyPaymentResponseEntity(
        success: false,
        registrationStatus: 'failed',
        bookingNumber: '',
        message: 'Server error (HTTP $statusCode)',
        isNetworkError: false,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        dynamic rawData = e.response!.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }
        final message = (rawData is Map && rawData['message'] != null)
            ? rawData['message'].toString()
            : 'Status check failed (HTTP ${e.response?.statusCode})';

        return WorkshopVerifyPaymentResponseEntity(
          success: false,
          registrationStatus: 'failed',
          bookingNumber: '',
          message: message,
          isNetworkError: false,
        );
      }
      return WorkshopVerifyPaymentResponseEntity.networkError(
        'Network error during status check: ${e.message ?? e.toString()}',
      );
    } catch (e) {
      return WorkshopVerifyPaymentResponseEntity(
        success: false,
        registrationStatus: 'failed',
        bookingNumber: '',
        message: 'Unexpected error during status check: ${e.toString()}',
        isNetworkError: false,
      );
    }
  }
}
