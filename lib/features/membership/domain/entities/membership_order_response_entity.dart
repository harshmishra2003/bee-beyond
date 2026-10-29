import 'package:equatable/equatable.dart';

class MembershipOrderResponseEntity extends Equatable {
  final bool success;
  final String message;
  final int membershipOrderId;
  final String orderNumber;
  final int planId;
  final String planName;
  final int planPriceId;
  final String billingPeriod;
  final int amountPaise;
  final String currency;
  final String razorpayOrderId;
  final String razorpayKeyId;

  const MembershipOrderResponseEntity({
    required this.success,
    required this.message,
    required this.membershipOrderId,
    required this.orderNumber,
    required this.planId,
    required this.planName,
    required this.planPriceId,
    required this.billingPeriod,
    required this.amountPaise,
    required this.currency,
    required this.razorpayOrderId,
    required this.razorpayKeyId,
  });

  factory MembershipOrderResponseEntity.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return MembershipOrderResponseEntity(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      membershipOrderId: (data['membership_order_id'] as num?)?.toInt() ?? 0,
      orderNumber: data['order_number']?.toString() ?? '',
      planId: (data['plan_id'] as num?)?.toInt() ?? 0,
      planName: data['plan_name']?.toString() ?? '',
      planPriceId: (data['plan_price_id'] as num?)?.toInt() ?? 0,
      billingPeriod: data['billing_period']?.toString() ?? '',
      amountPaise: (data['amount'] as num?)?.toInt() ?? 0,
      currency: data['currency']?.toString() ?? 'INR',
      razorpayOrderId: data['razorpay_order_id']?.toString() ?? '',
      razorpayKeyId: data['razorpay_key_id']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        success,
        message,
        membershipOrderId,
        orderNumber,
        planId,
        planName,
        planPriceId,
        billingPeriod,
        amountPaise,
        currency,
        razorpayOrderId,
        razorpayKeyId,
      ];
}
