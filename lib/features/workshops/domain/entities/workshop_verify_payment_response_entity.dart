import 'package:equatable/equatable.dart';

class WorkshopVerifyPaymentResponseEntity extends Equatable {
  final bool success;
  final String registrationStatus;
  final String bookingNumber;
  final String message;
  final String paymentStatus;
  final String orderStatus;
  final double amount;
  final String currency;
  final bool isNetworkError;

  const WorkshopVerifyPaymentResponseEntity({
    required this.success,
    required this.registrationStatus,
    required this.bookingNumber,
    required this.message,
    this.paymentStatus = '',
    this.orderStatus = '',
    this.amount = 0.0,
    this.currency = 'INR',
    this.isNetworkError = false,
  });

  bool get isConfirmed => success && registrationStatus.toLowerCase() == 'confirmed';

  bool get isDefinitivelyFailed {
    final status = registrationStatus.toLowerCase();
    return status == 'failed' || status == 'cancelled' || status == 'rejected';
  }

  bool get isRefundReview {
    final status = registrationStatus.toLowerCase();
    return status == 'refund_pending' ||
        status == 'under_review' ||
        status == 'refund_initiated' ||
        status == 'refund_review';
  }

  factory WorkshopVerifyPaymentResponseEntity.fromJson(Map<String, dynamic> json) {
    final bool isSuccess = json['success'] == true || json['status'] == 'success';

    final Map<String, dynamic> dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final statusStr = (dataMap['registration_status'] ??
            dataMap['status'] ??
            json['registration_status'] ??
            '')
        .toString()
        .toLowerCase()
        .trim();

    final pStatus = (dataMap['payment_status'] ?? json['payment_status'] ?? '').toString();
    final oStatus = (dataMap['order_status'] ?? json['order_status'] ?? '').toString();
    final rawAmt = dataMap['amount'] ?? json['amount'];
    final parsedAmt = (rawAmt as num?)?.toDouble() ?? 0.0;
    final curr = (dataMap['currency'] ?? json['currency'] ?? 'INR').toString();
    final msg = (dataMap['message'] ?? json['message'] ?? '').toString();

    return WorkshopVerifyPaymentResponseEntity(
      success: isSuccess,
      registrationStatus: statusStr,
      bookingNumber: (dataMap['booking_number'] ?? json['booking_number'] ?? '').toString(),
      message: msg,
      paymentStatus: pStatus,
      orderStatus: oStatus,
      amount: parsedAmt,
      currency: curr,
      isNetworkError: false,
    );
  }

  factory WorkshopVerifyPaymentResponseEntity.networkError(String msg) {
    return WorkshopVerifyPaymentResponseEntity(
      success: false,
      registrationStatus: 'pending',
      bookingNumber: '',
      message: msg,
      isNetworkError: true,
    );
  }

  @override
  List<Object?> get props => [
        success,
        registrationStatus,
        bookingNumber,
        message,
        paymentStatus,
        orderStatus,
        amount,
        currency,
        isNetworkError,
      ];
}
