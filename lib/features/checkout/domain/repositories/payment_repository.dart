import '../entities/payment_entity.dart';

abstract class PaymentRepository {
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
