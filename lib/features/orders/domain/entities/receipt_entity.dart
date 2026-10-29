class ReceiptItem {
  final String name;
  final int quantity;
  final double unitPrice;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReceiptEntity {
  final String receiptId;
  final String orderId;
  final String title;
  final String type; // 'COURSE', 'PRODUCT', 'SERVICE', 'MEMBERSHIP'
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String deliveryAddress;
  final List<ReceiptItem> items;
  final double subtotal;
  final double gstRate; // e.g. 0.18 (18%)
  final double deliveryFee;
  final double discount;
  final String paymentMethod;
  final DateTime date;

  const ReceiptEntity({
    required this.receiptId,
    required this.orderId,
    required this.title,
    required this.type,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    this.gstRate = 0.18,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
    required this.paymentMethod,
    required this.date,
  });

  double get cgst => (subtotal * gstRate) / 2;
  double get sgst => (subtotal * gstRate) / 2;
  double get totalGst => subtotal * gstRate;
  double get grandTotal => subtotal + totalGst + deliveryFee - discount;

  Map<String, dynamic> toJson() {
    return {
      'receiptId': receiptId,
      'orderId': orderId,
      'title': title,
      'type': type,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'deliveryAddress': deliveryAddress,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'gstRate': gstRate,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
    };
  }

  factory ReceiptEntity.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ReceiptEntity(
      receiptId: json['receiptId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'COURSE',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      items: rawItems.map((i) => ReceiptItem.fromJson(i as Map<String, dynamic>)).toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 0.18,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'Online Portal',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}
