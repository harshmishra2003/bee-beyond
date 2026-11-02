import 'package:equatable/equatable.dart';

class WorkshopOrderResponseEntity extends Equatable {
  final bool success;
  final String message;
  final int workshopOrderId;
  final int registrationId;
  final String bookingNumber;
  final int amount; // Amount in paise
  final String currency;
  final String razorpayOrderId;
  final String razorpayKeyId;

  const WorkshopOrderResponseEntity({
    required this.success,
    required this.message,
    required this.workshopOrderId,
    required this.registrationId,
    required this.bookingNumber,
    required this.amount,
    required this.currency,
    required this.razorpayOrderId,
    required this.razorpayKeyId,
  });

  factory WorkshopOrderResponseEntity.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final int parsedOrderId = (data['workshop_order_id'] as num?)?.toInt() ??
        (data['order_id'] as num?)?.toInt() ??
        (json['workshop_order_id'] as num?)?.toInt() ??
        0;

    final int parsedRegistrationId = (data['registration_id'] as num?)?.toInt() ??
        (json['registration_id'] as num?)?.toInt() ??
        0;

    final int parsedAmount = (data['amount'] as num?)?.toInt() ??
        (json['amount'] as num?)?.toInt() ??
        0;

    return WorkshopOrderResponseEntity(
      success: json['success'] == true || json['status'] == 'success',
      message: (json['message'] ?? data['message'] ?? '').toString(),
      workshopOrderId: parsedOrderId,
      registrationId: parsedRegistrationId,
      bookingNumber: (data['booking_number'] ?? json['booking_number'] ?? '').toString(),
      amount: parsedAmount,
      currency: (data['currency'] ?? json['currency'] ?? 'INR').toString(),
      razorpayOrderId: (data['razorpay_order_id'] ?? json['razorpay_order_id'] ?? '').toString(),
      razorpayKeyId: (data['razorpay_key_id'] ?? json['razorpay_key_id'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
        success,
        message,
        workshopOrderId,
        registrationId,
        bookingNumber,
        amount,
        currency,
        razorpayOrderId,
        razorpayKeyId,
      ];
}
