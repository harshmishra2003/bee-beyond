import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String orderId;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final int totalItems;
  final String title;
  final String imageUrl;
  final String paymentStatus;
  final String paymentMethod;
  final double subtotalAmount;
  final double discountAmount;
  final double shippingFee;
  final double taxAmount;

  const OrderEntity({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.totalItems,
    this.title = '',
    this.imageUrl = '',
    this.paymentStatus = 'PAID',
    this.paymentMethod = 'Razorpay UPI / Online',
    this.subtotalAmount = 0.0,
    this.discountAmount = 0.0,
    this.shippingFee = 0.0,
    this.taxAmount = 0.0,
  });

  @override
  List<Object?> get props => [
        orderId,
        status,
        totalAmount,
        orderDate,
        totalItems,
        title,
        imageUrl,
        paymentStatus,
        paymentMethod,
        subtotalAmount,
        discountAmount,
        shippingFee,
        taxAmount,
      ];
}
