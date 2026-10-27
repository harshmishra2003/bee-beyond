import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.status,
    required super.totalAmount,
    required super.orderDate,
    required super.totalItems,
    super.title,
    super.imageUrl,
    super.paymentStatus,
    super.paymentMethod,
    super.subtotalAmount,
    super.discountAmount,
    super.shippingFee,
    super.taxAmount,
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

    final rawTitle = json['title']?.toString() ??
        json['product_title']?.toString() ??
        json['item_title']?.toString() ??
        json['name']?.toString() ??
        json['product_name']?.toString() ??
        '';

    final rawImageUrl = json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['thumbnail']?.toString() ??
        json['product_image']?.toString() ??
        '';

    final rawPaymentStatus = json['payment_status']?.toString() ??
        json['paid_status']?.toString() ??
        json['pay_status']?.toString() ??
        (rawStatus.toLowerCase().contains('delivered') ||
                rawStatus.toLowerCase().contains('transit') ||
                rawStatus.toLowerCase().contains('access') ||
                rawStatus.toLowerCase().contains('completed') ||
                rawStatus.toLowerCase().contains('processing')
            ? 'PAID'
            : 'PENDING');

    final rawPaymentMethod = json['payment_method']?.toString() ??
        json['pay_method']?.toString() ??
        'Razorpay UPI / Online';

    double subtotal = double.tryParse(json['subtotal']?.toString() ?? '') ??
        double.tryParse(json['subtotal_amount']?.toString() ?? '') ??
        (amount > 0 ? (amount * 1.1) : 0.0);

    double discount = double.tryParse(json['discount']?.toString() ?? '') ??
        double.tryParse(json['discount_amount']?.toString() ?? '') ??
        (subtotal > amount ? (subtotal - amount) : 0.0);

    double shipping = double.tryParse(json['shipping_fee']?.toString() ?? '') ??
        double.tryParse(json['delivery_charge']?.toString() ?? '') ??
        0.0;

    double tax = double.tryParse(json['tax']?.toString() ?? '') ??
        double.tryParse(json['tax_amount']?.toString() ?? '') ??
        0.0;

    return OrderModel(
      orderId: rawOrderId,
      status: rawStatus,
      totalAmount: amount,
      orderDate: date,
      totalItems: itemsCount > 0 ? itemsCount : 1,
      title: rawTitle,
      imageUrl: rawImageUrl,
      paymentStatus: rawPaymentStatus.toUpperCase(),
      paymentMethod: rawPaymentMethod,
      subtotalAmount: subtotal,
      discountAmount: discount,
      shippingFee: shipping,
      taxAmount: tax,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'status': status,
      'total_amount': totalAmount,
      'order_date': orderDate.toIso8601String(),
      'total_items': totalItems,
      'title': title,
      'image_url': imageUrl,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'subtotal_amount': subtotalAmount,
      'discount_amount': discountAmount,
      'shipping_fee': shippingFee,
      'tax_amount': taxAmount,
    };
  }
}
