import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String orderId;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final int totalItems;

  const OrderEntity({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.totalItems,
  });

  @override
  List<Object?> get props => [orderId, status, totalAmount, orderDate, totalItems];
}
