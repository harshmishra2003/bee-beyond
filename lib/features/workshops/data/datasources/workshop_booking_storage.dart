import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WorkshopBookingStorage {
  static const String _prefix = 'pending_workshop_booking_';

  Future<void> savePendingBooking({
    required int workshopId,
    required int workshopOrderId,
    required String razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
    double? amount,
    String? attendeeName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'workshop_id': workshopId,
        'workshop_order_id': workshopOrderId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId ?? '',
        'razorpay_signature': razorpaySignature ?? '',
        'amount': amount ?? 0.0,
        'attendee_name': attendeeName ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      };
      await prefs.setString('$_prefix$workshopId', jsonEncode(data));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getPendingBooking(int workshopId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_prefix$workshopId');
      if (jsonStr != null && jsonStr.trim().isNotEmpty) {
        final decoded = jsonDecode(jsonStr.trim());
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearPendingBooking(int workshopId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$workshopId');
    } catch (_) {}
  }
}
