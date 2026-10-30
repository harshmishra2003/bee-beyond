import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onError;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) {
      onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onError != null) {
      onError!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  void openCheckout({
    required String keyId,
    required int amountPaise,
    required String gatewayOrderId,
    required String name,
    required String description,
    required String contact,
    required String email,
    required String customerName,
  }) {
    var options = {
      'key': keyId,
      'amount': amountPaise, // in paise
      'name': name,
      'description': description,
      'order_id': gatewayOrderId, // Real Razorpay order ID from create_order.php
      'prefill': {
        'contact': contact,
        'email': email,
        'name': customerName,
      },
      'theme': {
        'color': '#12683A',
      },
    };

    try {
      _razorpay.open(options);
    } catch (_) {}
  }

  void dispose() {
    _razorpay.clear();
  }
}
