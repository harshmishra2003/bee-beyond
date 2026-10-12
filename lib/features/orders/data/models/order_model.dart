import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.status,
    required super.totalAmount,
    required super.orderDate,
    required super.totalItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? '',
      status: json['status'] ?? 'Placed',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      orderDate: DateTime.parse(json['order_date'] ?? DateTime.now().toIso8601String()),
      totalItems: json['total_items'] ?? 1,
    );
  }
}
