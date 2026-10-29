import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_ds.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<PaymentOrderEntity> createServerOrder({
    required double amount,
    required String currency,
    required String receiptId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      return await remoteDataSource.createServerOrder(
        amount: amount,
        currency: currency,
        receiptId: receiptId,
        items: items,
      );
    } catch (e) {
      throw Exception('Server API Error: Could not create payment order. $e');
    }
  }

  @override
  Future<PaymentVerificationEntity> verifyPaymentSignature({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    return await remoteDataSource.verifyPaymentSignature(
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }

  @override
  Future<PaymentResultEntity> executeFallbackPayment({
    required String orderId,
    required double amount,
    required String gatewayName,
  }) async {
    return await remoteDataSource.executeFallbackPayment(
      orderId: orderId,
      amount: amount,
      gatewayName: gatewayName,
    );
  }
}
