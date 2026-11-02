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

      if (response.statusCode == 200 && response.data != null) {
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

        if (response.statusCode == 200 && response.data != null) {
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
      );

      if (response.data != null) {
        dynamic rawData = response.data;
        if (rawData is String) {
          rawData = jsonDecode(rawData);
        }

        if (rawData is Map<String, dynamic>) {
          return WorkshopOrderResponseEntity.fromJson(rawData);
        } else if (rawData is Map) {
          return WorkshopOrderResponseEntity.fromJson(Map<String, dynamic>.from(rawData));
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
      );

      if (response.data != null) {
        dynamic rawData = response.data;
        if (rawData is String) {
          rawData = jsonDecode(rawData);
        }

        if (rawData is Map<String, dynamic>) {
          return WorkshopVerifyPaymentResponseEntity.fromJson(rawData);
        } else if (rawData is Map) {
          return WorkshopVerifyPaymentResponseEntity.fromJson(Map<String, dynamic>.from(rawData));
        }
      }

      return WorkshopVerifyPaymentResponseEntity(
        success: false,
        registrationStatus: 'failed',
        bookingNumber: '',
        message: 'Server responded with status ${response.statusCode}',
      );
    } catch (e) {
      return WorkshopVerifyPaymentResponseEntity.networkError(
        'Network exception during payment verification: ${e.toString()}',
      );
    }
  }
}
