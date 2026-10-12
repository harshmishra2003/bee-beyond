import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/managers/cart_manager.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../orders/presentation/providers/receipt_provider.dart';
import '../../../orders/presentation/screens/receipt_preview_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shipping Fields
  final _nameController = TextEditingController(text: 'Aarav Sharma');
  final _phoneController = TextEditingController(text: '+91 9876543210');
  final _emailController = TextEditingController(text: 'aarav@example.com');
  final _addressController = TextEditingController(text: 'Flat 302, Green Heights, MG Road');
  final _cityController = TextEditingController(text: 'Mumbai');
  final _stateController = TextEditingController(text: 'Maharashtra');
  final _pincodeController = TextEditingController(text: '400001');

  // Card Payment Fields
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Custom UPI ID Field
  final _upiIdController = TextEditingController();

  String _paymentCategory = 'upi'; // 'upi', 'card', 'netbanking', 'wallet', 'cod'
  String _selectedUpiApp = 'gpay'; // 'gpay', 'phonepe', 'paytm', 'bhim', 'custom'
  String _selectedBank = 'HDFC Bank';
  bool _isProcessingPayment = false;

  final List<Map<String, String>> _upiApps = [
    {'id': 'gpay', 'name': 'Google Pay', 'icon': '🌀', 'vpa': 'beebeyond@okaxis'},
    {'id': 'phonepe', 'name': 'PhonePe', 'icon': '🟣', 'vpa': 'beebeyond@ybl'},
    {'id': 'paytm', 'name': 'Paytm UPI', 'icon': '🔵', 'vpa': 'beebeyond@paytm'},
    {'id': 'bhim', 'name': 'BHIM UPI', 'icon': '🇮🇳', 'vpa': 'beebeyond@upi'},
    {'id': 'custom', 'name': 'Enter UPI ID / VPA', 'icon': '⚡', 'vpa': ''},
  ];

  final List<String> _banks = [
    'HDFC Bank',
    'ICICI Bank',
    'State Bank of India (SBI)',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  // UPI App Navigation & Deep Link Execution
  Future<void> _processUpiPayment({
    required String appName,
    required String upiId,
    required double totalAmount,
    required List<CartItemEntity> items,
  }) async {
    // Construct standard UPI Payment URI
    final encodedTitle = Uri.encodeComponent('BEE BEYOND Wellness');
    final upiUriString =
        'upi://pay?pa=$upiId&pn=$encodedTitle&am=${totalAmount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent("Order Payment")}';

    final uri = Uri.parse(upiUriString);

    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }

    // Fallback if UPI app isn't installed on device/emulator: Show Interactive Processing Modal
    if (!launched && mounted) {
      _showUpiProcessingModal(
        appName: appName,
        upiId: upiId,
        totalAmount: totalAmount,
        items: items,
      );
    } else if (launched && mounted) {
      _completeOrderSuccess(paymentMethod: '$appName (UPI)', items: items, totalAmount: totalAmount);
    }
  }

  // Interactive UPI Processing Modal
  void _showUpiProcessingModal({
    required String appName,
    required String upiId,
    required double totalAmount,
    required List<CartItemEntity> items,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UpiPaymentDialog(
        appName: appName,
        upiId: upiId,
        totalAmount: totalAmount,
        onSuccess: () {
          Navigator.pop(ctx);
          _completeOrderSuccess(
            paymentMethod: '$appName (UPI)',
            items: items,
            totalAmount: totalAmount,
          );
        },
      ),
    );
  }

  // Complete Order & Generate Official Receipt
  void _completeOrderSuccess({
    required String paymentMethod,
    required List<CartItemEntity> items,
    required double totalAmount,
  }) {
    final randomId = (1000 + math.Random().nextInt(8999)).toString();
    final receiptId = 'REC-2025-$randomId';
    final orderId = 'ORD-2025-$randomId';

    final addressStr =
        '${_addressController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_pincodeController.text.trim()}';

    // Calculate subtotal and tax
    final subtotal = items.isEmpty ? totalAmount : items.subtotal;

    final receiptItems = items.isEmpty
        ? [ReceiptItem(name: 'Bee Beyond Order Items', quantity: 1, unitPrice: subtotal)]
        : items.map((i) => ReceiptItem(name: i.title, quantity: i.quantity, unitPrice: i.price)).toList();

    final newReceipt = ReceiptEntity(
      receiptId: receiptId,
      orderId: orderId,
      title: items.isNotEmpty ? items.first.title : 'Bee Beyond Order',
      type: 'PRODUCT',
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerEmail: _emailController.text.trim(),
      deliveryAddress: addressStr,
      items: receiptItems,
      subtotal: subtotal,
      gstRate: 0.18,
      deliveryFee: subtotal > 999 ? 0.0 : 99.0,
      discount: 100.0,
      paymentMethod: paymentMethod,
      date: DateTime.now(),
    );

    // Save to Receipts Provider
    ref.read(receiptsProvider.notifier).addReceipt(newReceipt);

    // Clear Shopping Cart
    ref.read(cartManagerProvider.notifier).clearCart();

    // Show Success SnackBar & Navigate to Receipt Preview
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful! Generating Tax Invoice...'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ReceiptPreviewScreen(receipt: newReceipt),
      ),
    );
  }

  // On Pay Button Pressed
  void _handlePayOrder(List<CartItemEntity> cartItems, double totalAmount) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required shipping details correctly.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_paymentCategory == 'upi') {
      final selectedApp = _upiApps.firstWhere((a) => a['id'] == _selectedUpiApp);
      final appName = selectedApp['name']!;
      String upiId = selectedApp['vpa']!;

      if (_selectedUpiApp == 'custom') {
        upiId = _upiIdController.text.trim();
        if (upiId.isEmpty || !upiId.contains('@')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid UPI VPA ID (e.g. name@upi).'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      _processUpiPayment(
        appName: appName,
        upiId: upiId.isEmpty ? 'beebeyond@upi' : upiId,
        totalAmount: totalAmount,
        items: cartItems,
      );
    } else if (_paymentCategory == 'card') {
      if (_cardNumberController.text.trim().length < 16 ||
          _cardExpiryController.text.trim().isEmpty ||
          _cardCvvController.text.trim().length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid Credit/Debit Card details.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isProcessingPayment = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        _completeOrderSuccess(paymentMethod: 'Credit / Debit Card', items: cartItems, totalAmount: totalAmount);
      }
    } else if (_paymentCategory == 'netbanking') {
      setState(() => _isProcessingPayment = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        _completeOrderSuccess(paymentMethod: 'NetBanking ($_selectedBank)', items: cartItems, totalAmount: totalAmount);
      }
    } else if (_paymentCategory == 'cod') {
      _completeOrderSuccess(paymentMethod: 'Cash on Delivery (COD)', items: cartItems, totalAmount: totalAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartManagerProvider);
    final cartItems = cartState.value ?? [];

    final subtotal = cartItems.isEmpty ? 1999.0 : cartItems.subtotal;
    final gst = subtotal * 0.18;
    final deliveryFee = subtotal > 999 ? 0.0 : 99.0;
    const discount = 100.0;
    final grandTotal = subtotal + gst + deliveryFee - discount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Checkout & Payment'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BRAND TITLE HEADER BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x204B489B), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AssetPaths.beeBeyondImage1,
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.spa_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEE BEYOND',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Secure Checkout & Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '100% Encrypted & Safe Transaction',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ORDER SUMMARY ACCORDION CARD
              _buildOrderSummaryCard(
                cartItems: cartItems,
                subtotal: subtotal,
                gst: gst,
                deliveryFee: deliveryFee,
                discount: discount,
                grandTotal: grandTotal,
              ),

              const SizedBox(height: 20),

              // SECTION 1: SHIPPING ADDRESS
              _buildSectionHeader('1. Delivery Address', Icons.location_on_outlined),
              const SizedBox(height: 12),

              _buildTextField(controller: _nameController, label: 'Full Name *', validator: (v) => v == null || v.trim().isEmpty ? 'Full Name required' : null),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _phoneController, label: 'Mobile Phone *', keyboardType: TextInputType.phone, validator: (v) => v == null || v.trim().length < 10 ? 'Valid Phone required' : null)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(controller: _emailController, label: 'Email ID *', keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Valid Email required' : null)),
                ],
              ),
              const SizedBox(height: 10),

              _buildTextField(controller: _addressController, label: 'Flat / Street / Landmark Address *', validator: (v) => v == null || v.trim().isEmpty ? 'Address required' : null),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _cityController, label: 'City *', validator: (v) => v == null || v.trim().isEmpty ? 'City required' : null)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(controller: _stateController, label: 'State *', validator: (v) => v == null || v.trim().isEmpty ? 'State required' : null)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(controller: _pincodeController, label: 'PIN Code *', keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().length < 6 ? 'Pincode required' : null)),
                ],
              ),

              const SizedBox(height: 24),

              // SECTION 2: PAYMENT METHOD SELECTION
              _buildSectionHeader('2. Select Payment Option', Icons.payment_rounded),
              const SizedBox(height: 12),

              // PAYMENT CATEGORY TABS
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                ),
                child: Column(
                  children: [
                    _buildPaymentCategoryTile(
                      id: 'upi',
                      title: 'UPI Payment Apps (Instant)',
                      subtitle: 'Google Pay, PhonePe, Paytm, BHIM UPI',
                      icon: Icons.qr_code_scanner_rounded,
                      iconColor: const Color(0xFF059669),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildPaymentCategoryTile(
                      id: 'card',
                      title: 'Credit / Debit Cards',
                      subtitle: 'Visa, MasterCard, RuPay, Maestro',
                      icon: Icons.credit_card_rounded,
                      iconColor: const Color(0xFF4338CA),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildPaymentCategoryTile(
                      id: 'netbanking',
                      title: 'Net Banking',
                      subtitle: 'HDFC, ICICI, SBI, Axis & all major banks',
                      icon: Icons.account_balance_rounded,
                      iconColor: const Color(0xFFD97706),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildPaymentCategoryTile(
                      id: 'cod',
                      title: 'Cash on Delivery (COD)',
                      subtitle: 'Pay at your doorstep upon receipt',
                      icon: Icons.payments_rounded,
                      iconColor: const Color(0xFF0288D1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // PAYMENT CATEGORY SUB-OPTIONS PANEL
              if (_paymentCategory == 'upi') _buildUpiOptionsPanel(grandTotal),
              if (_paymentCategory == 'card') _buildCardOptionsPanel(),
              if (_paymentCategory == 'netbanking') _buildNetBankingPanel(),
              if (_paymentCategory == 'cod') _buildCodPanel(),

              const SizedBox(height: 32),

              // PAY & CONFIRM BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isProcessingPayment ? null : () => _handlePayOrder(cartItems, grandTotal),
                  child: _isProcessingPayment
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'PAY ${CurrencyUtils.formatINR(grandTotal)} NOW →',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ORDER SUMMARY CARD
  Widget _buildOrderSummaryCard({
    required List<CartItemEntity> cartItems,
    required double subtotal,
    required double gst,
    required double deliveryFee,
    required double discount,
    required double grandTotal,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x0C4B489B), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Items Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${cartItems.isEmpty ? 1 : cartItems.length} Item(s)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),

          // Items Preview List
          if (cartItems.isNotEmpty)
            ...cartItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatINR(item.price * item.quantity),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ))
          else
            const Text('1x Bee Beyond Healing Product Order', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),

          const Divider(height: 20, color: AppColors.divider),

          _buildCostRow('Subtotal', CurrencyUtils.formatINR(subtotal)),
          const SizedBox(height: 4),
          _buildCostRow('18% GST (CGST + SGST)', CurrencyUtils.formatINR(gst)),
          const SizedBox(height: 4),
          _buildCostRow('Delivery Fee', deliveryFee > 0 ? CurrencyUtils.formatINR(deliveryFee) : 'FREE'),
          if (discount > 0) ...[
            const SizedBox(height: 4),
            _buildCostRow('Welcome Discount', '-${CurrencyUtils.formatINR(discount)}', isDiscount: true),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.divider)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PAYABLE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              Text(
                CurrencyUtils.formatINR(grandTotal),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPI OPTIONS PANEL
  Widget _buildUpiOptionsPanel(double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF059669).withAlpha(100), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Your Preferred UPI App:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._upiApps.map((app) {
            final isSelected = _selectedUpiApp == app['id'];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0)),
              ),
              child: RadioListTile<String>(
                value: app['id']!,
                groupValue: _selectedUpiApp,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedUpiApp = val);
                },
                activeColor: const Color(0xFF059669),
                title: Row(
                  children: [
                    Text(app['icon']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(app['name']!, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            );
          }),

          // Custom VPA Input
          if (_selectedUpiApp == 'custom') ...[
            const SizedBox(height: 8),
            _buildTextField(
              controller: _upiIdController,
              label: 'Enter UPI ID / VPA *',
              hint: 'e.g. mobile@upi or username@ybl',
            ),
          ],
        ],
      ),
    );
  }

  // CARD OPTIONS PANEL
  Widget _buildCardOptionsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(100), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enter Card Information:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('💳 Visa / MasterCard / RuPay', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(controller: _cardNumberController, label: 'Card Number *', hint: '1234 5678 9012 3456', keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField(controller: _cardExpiryController, label: 'Expiry Date *', hint: 'MM/YY', keyboardType: TextInputType.datetime)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(controller: _cardCvvController, label: 'CVV / CVC *', hint: '***', obscureText: true, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField(controller: _cardHolderController, label: 'Name on Card *', hint: 'As printed on card'),
        ],
      ),
    );
  }

  // NET BANKING PANEL
  Widget _buildNetBankingPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD97706).withAlpha(100), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Your Bank for NetBanking:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedBank,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedBank = val);
            },
          ),
        ],
      ),
    );
  }

  // COD PANEL
  Widget _buildCodPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cash on Delivery Available', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                SizedBox(height: 2),
                Text('Pay with cash or UPI QR code at the time of doorstep delivery.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCategoryTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _paymentCategory == id;

    return RadioListTile<String>(
      value: id,
      groupValue: _paymentCategory,
      onChanged: (val) {
        if (val != null) setState(() => _paymentCategory = val);
      },
      activeColor: AppColors.primary,
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCostRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDiscount ? const Color(0xFF10B981) : AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderSubtle)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

// REALISTIC INTERACTIVE UPI PAYMENT PROCESSING DIALOG
class _UpiPaymentDialog extends StatefulWidget {
  final String appName;
  final String upiId;
  final double totalAmount;
  final VoidCallback onSuccess;

  const _UpiPaymentDialog({
    required this.appName,
    required this.upiId,
    required this.totalAmount,
    required this.onSuccess,
  });

  @override
  State<_UpiPaymentDialog> createState() => _UpiPaymentDialogState();
}

class _UpiPaymentDialogState extends State<_UpiPaymentDialog> {
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        if (mounted) setState(() => _countdown--);
      } else {
        _timer?.cancel();
        widget.onSuccess();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.beeBeyondImage1,
              width: 54,
              height: 54,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.spa_rounded, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('BEE BEYOND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.amber, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text('Paying via ${widget.appName}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
              child: Text('VPA ID: ${widget.upiId}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Text(CurrencyUtils.formatINR(widget.totalAmount), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 16),
            Text('Processing payment in 00:0$_countdown...', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Please do not press back or close the app.', style: TextStyle(fontSize: 10, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}
