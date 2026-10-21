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
    final rawOrderId = json['order_id']?.toString() ??
        json['orderId']?.toString() ??
        json['id']?.toString() ??
        json['receipt_id']?.toString() ??
        'ORD-${DateTime.now().millisecondsSinceEpoch}';

    final rawStatus = json['status']?.toString() ??
        json['order_status']?.toString() ??
        json['payment_status']?.toString() ??
        'Processing';

    final rawAmount = json['total_amount'] ??
        json['totalAmount'] ??
        json['total_price'] ??
        json['amount'] ??
        json['subtotal'] ??
        0.0;

    double amount = 0.0;
    if (rawAmount is num) {
      amount = rawAmount.toDouble();
    } else if (rawAmount != null) {
      amount = double.tryParse(rawAmount.toString()) ?? 0.0;
    }

    final rawDate = json['order_date']?.toString() ??
        json['created_at']?.toString() ??
        json['date']?.toString();

    DateTime date = DateTime.now();
    if (rawDate != null && rawDate.isNotEmpty) {
      date = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    final rawItems = json['total_items'] ??
        json['totalItems'] ??
        json['items_count'] ??
        (json['items'] is List ? (json['items'] as List).length : 1);

    int itemsCount = 1;
    if (rawItems is num) {
      itemsCount = rawItems.toInt();
    } else if (rawItems != null) {
      itemsCount = int.tryParse(rawItems.toString()) ?? 1;
    }

    return OrderModel(
      orderId: rawOrderId,
      status: rawStatus,
      totalAmount: amount,
      orderDate: date,
      totalItems: itemsCount > 0 ? itemsCount : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'status': status,
      'total_amount': totalAmount,
      'order_date': orderDate.toIso8601String(),
      'total_items': totalItems,
    };
  }
}
