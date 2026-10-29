import 'package:equatable/equatable.dart';

class PaymentOrderEntity extends Equatable {
  final String orderId;
  final int localOrderId;
  final String gatewayOrderId;
  final String keyId;
  final int amountPaise;
  final double amountRupees;
  final String currency;
  final String? signatureChecksum;

  const PaymentOrderEntity({
    required this.orderId,
    required this.localOrderId,
    required this.gatewayOrderId,
    required this.keyId,
    required this.amountPaise,
    required this.amountRupees,
    this.currency = 'INR',
    this.signatureChecksum,
  });

  @override
  List<Object?> get props => [
        orderId,
        localOrderId,
        gatewayOrderId,
        keyId,
        amountPaise,
        amountRupees,
        currency,
        signatureChecksum,
      ];
}

class PaymentResultEntity extends Equatable {
  final String paymentId;
  final String orderId;
  final String? signature;
  final String status; // 'SUCCESS', 'FAILED', 'CANCELLED'
  final String message;

  const PaymentResultEntity({
    required this.paymentId,
    required this.orderId,
    this.signature,
    required this.status,
    required this.message,
  });

  bool get isSuccess => status.toUpperCase() == 'SUCCESS';

  @override
  List<Object?> get props => [paymentId, orderId, signature, status, message];
}

class PaymentVerificationEntity extends Equatable {
  final bool isVerified;
  final String status;
  final String transactionId;
  final String message;

  const PaymentVerificationEntity({
    required this.isVerified,
    required this.status,
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object?> get props => [isVerified, status, transactionId, message];
}
