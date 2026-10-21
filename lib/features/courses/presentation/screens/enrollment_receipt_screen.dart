import 'package:flutter/material.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../orders/presentation/screens/receipt_preview_screen.dart';

class EnrollmentReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const EnrollmentReceiptScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final enrollmentId = data['enrollmentId'] ?? 'ENR-2025-9981';
    final studentName = data['studentName'] ?? 'Student Name';
    final courseTitle = data['courseTitle'] ?? 'Wellness Course';
    final coursePrice = (data['coursePrice'] as double?) ?? 2499.0;
    final email = data['email'] ?? 'student@gmail.com';
    final phone = data['phone'] ?? '+91 9876543210';
    final address = data['address'] ?? 'Mumbai, India';

    final receipt = ReceiptEntity(
      receiptId: enrollmentId,
      orderId: enrollmentId,
      title: courseTitle,
      type: 'COURSE',
      customerName: studentName,
      customerPhone: phone,
      customerEmail: email,
      deliveryAddress: address,
      items: [
        ReceiptItem(name: courseTitle, quantity: 1, unitPrice: coursePrice),
      ],
      subtotal: coursePrice,
      gstRate: 0.18,
      deliveryFee: 0.0,
      discount: 0.0,
      paymentMethod: 'UPI / Online Portal',
      date: DateTime.now(),
    );

    return ReceiptPreviewScreen(receipt: receipt);
  }
}
