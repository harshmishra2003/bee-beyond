import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/payment_entity.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentOrderEntity> createServerOrder({
    required double amount,
    required String currency,
    required String receiptId,
    required List<Map<String, dynamic>> items,
  });

  Future<PaymentVerificationEntity> verifyPaymentSignature({
    required String paymentId,
    required String orderId,
    required String signature,
  });

  Future<PaymentResultEntity> executeFallbackPayment({
    required String orderId,
    required double amount,
    required String gatewayName,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final DioClient _dioClient;

  PaymentRemoteDataSourceImpl(this._dioClient);

  Dio get _dio => _dioClient.instance;

  @override
  Future<PaymentOrderEntity> createServerOrder({
    required double amount,
    required String currency,
    required String receiptId,
    required List<Map<String, dynamic>> items,
  }) async {
    // Format items as required by /checkout/create_order.php
    final formattedItems = items.map((item) {
      final rawId = item['product_id'] ?? item['id'] ?? 1;
      final productId = rawId is int ? rawId : (int.tryParse('$rawId') ?? 1);
      final rawQty = item['quantity'] ?? 1;
      final quantity = rawQty is int ? rawQty : (int.tryParse('$rawQty') ?? 1);

      return {
        'product_id': productId <= 0 ? 1 : productId,
        'quantity': quantity <= 0 ? 1 : quantity,
      };
    }).toList();

    final response = await _dio.post(
      ApiEndpoints.createOrder,
      data: {
        'items': formattedItems,
      },
    );

    final raw = response.data;
    if (raw is! Map<String, dynamic> || raw['success'] != true || raw['data'] is! Map) {
      throw Exception(raw['message']?.toString() ?? 'Could not create payment order.');
    }

    final data = Map<String, dynamic>.from(raw['data'] as Map);

    final gatewayOrderId = data['gateway_order_id']?.toString() ?? '';
    final keyId = data['key_id']?.toString() ?? '';
    final localOrderIdStr = data['local_order_id']?.toString();
    final amountStr = data['amount']?.toString();
    
    final localOrderId = localOrderIdStr != null ? int.tryParse(localOrderIdStr) : null;
    final amountPaise = amountStr != null ? int.tryParse(amountStr) : null;
    
    if (gatewayOrderId.isEmpty || keyId.isEmpty || localOrderId == null || amountPaise == null) {
      throw Exception('The server returned incomplete order details.');
    }

    final orderNumber = data['order_id']?.toString() ?? gatewayOrderId;

    return PaymentOrderEntity(
      orderId: orderNumber,
      localOrderId: localOrderId,
      gatewayOrderId: gatewayOrderId,
      keyId: keyId,
      amountPaise: amountPaise,
      amountRupees: amountPaise / 100.0,
      currency: data['currency']?.toString() ?? 'INR',
    );
  }

  @override
  Future<PaymentVerificationEntity> verifyPaymentSignature({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    if (paymentId.trim().isEmpty || signature.trim().isEmpty) {
      return PaymentVerificationEntity(
        isVerified: false,
        status: 'FAILED',
        transactionId: paymentId,
        message: 'Invalid payment signature or missing transaction details.',
      );
    }

    try {
      debugPrint('🌐 [HTTP POST REQUEST] Sending verification data to API: ${ApiEndpoints.verifyPayment}');
      debugPrint('   👉 razorpay_payment_id: $paymentId');
      debugPrint('   👉 razorpay_order_id: $orderId');
      debugPrint('   👉 razorpay_signature: $signature');

      final response = await _dio.post(
        ApiEndpoints.verifyPayment,
        data: {
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        },
      );

      debugPrint('🌐 [HTTP POST RESPONSE] Status Code: ${response.statusCode}');
      debugPrint('   👉 Response Body: ${response.data}');

      if (response.data != null) {
        dynamic raw = response.data;
        if (raw is String) {
          try {
            raw = jsonDecode(raw);
          } catch (_) {}
        }

        if (raw is Map) {
          final body = Map<String, dynamic>.from(raw);

          // Extract payment status string from various possible DB fields in PHP backend response
          final rawStatus = (body['status'] ?? 
                             body['payment_status'] ?? 
                             body['data']?['status'] ?? 
                             body['data']?['payment_status'] ?? 
                             '').toString().toUpperCase();

          // Explicit failed, pending, or cancelled statuses in database
          final isExplicitlyFailed = rawStatus == 'FAILED' || 
                                     rawStatus == 'CANCELLED' || 
                                     rawStatus == 'PENDING' || 
                                     rawStatus == 'DISMISSED' || 
                                     rawStatus == 'DECLINED' || 
                                     rawStatus == 'ERROR';

          // Cryptographic signature check or explicit is_verified boolean
          final isSignatureVerified = body['is_verified'] == true || 
                                      body['data']?['is_verified'] == true;

          // Explicit success status in database
          final isStatusSuccess = rawStatus == 'SUCCESS' || 
                                  rawStatus == 'CAPTURED' || 
                                  rawStatus == 'PAID';

          final isApiSuccess = body['success'] == true || body['status'] == 'success';

          // Payment is ONLY verified if:
          // 1. API returned success
          // 2. Status in DB is NOT explicitly failed/pending/cancelled
          // 3. Either signature is explicitly verified OR status in DB is SUCCESS/CAPTURED/PAID
          final isVerified = isApiSuccess && !isExplicitlyFailed && (isSignatureVerified || isStatusSuccess);

          final message = body['message']?.toString() ??
              (isVerified
                  ? 'Payment verified successfully.'
                  : (isExplicitlyFailed
                      ? 'Payment status in database is $rawStatus.'
                      : 'Cryptographic signature or status verification failed.'));

          debugPrint('📊 [VERIFICATION PARSED]');
          debugPrint('   👉 isVerified: $isVerified');
          debugPrint('   👉 rawStatus: "$rawStatus"');
          debugPrint('   👉 Message: "$message"');

          return PaymentVerificationEntity(
            isVerified: isVerified,
            status: isVerified ? 'SUCCESS' : (rawStatus.isNotEmpty ? rawStatus : 'FAILED'),
            transactionId: paymentId,
            message: message,
          );
        }
      }
    } on DioException catch (e) {
      debugPrint('🚨 [DIO EXCEPTION IN VERIFICATION] Status Code: ${e.response?.statusCode}, Error: ${e.message}, Response: ${e.response?.data}');
      if (e.response != null) {
        dynamic raw = e.response!.data;
        if (raw is String) {
          try {
            raw = jsonDecode(raw);
          } catch (_) {}
        }
        String? serverMessage;
        if (raw is Map) {
          serverMessage = raw['message']?.toString();
        }
        if (e.response!.statusCode == 500) {
          return PaymentVerificationEntity(
            isVerified: false,
            status: 'FAILED',
            transactionId: paymentId,
            message: serverMessage ?? 'Server Error (HTTP 500) in /checkout/verify-payment.php backend script. Check server PHP logs.',
          );
        }
        if (serverMessage != null && serverMessage.isNotEmpty) {
          return PaymentVerificationEntity(
            isVerified: false,
            status: 'FAILED',
            transactionId: paymentId,
            message: serverMessage,
          );
        }
      }
      return PaymentVerificationEntity(
        isVerified: false,
        status: 'FAILED',
        transactionId: paymentId,
        message: 'Could not connect to verification server (${e.message}).',
      );
    } catch (e) {
      return PaymentVerificationEntity(
        isVerified: false,
        status: 'FAILED',
        transactionId: paymentId,
        message: 'Verification failed: $e',
      );
    }

    return PaymentVerificationEntity(
      isVerified: false,
      status: 'FAILED',
      transactionId: paymentId,
      message: 'Unparseable response from verification endpoint.',
    );
  }

  @override
  Future<PaymentResultEntity> executeFallbackPayment({
    required String orderId,
    required double amount,
    required String gatewayName,
  }) async {
    return const PaymentResultEntity(
      paymentId: '',
      orderId: '',
      status: 'FAILED',
      message: 'Simulated payments are disabled.',
    );
  }
}
