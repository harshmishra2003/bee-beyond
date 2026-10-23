import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/managers/cart_manager.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../orders/presentation/providers/receipt_provider.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/razorpay_service.dart';
import '../../../../core/utils/payment_validators.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_processing_sheet.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final CartItemEntity? directItem;

  const CheckoutScreen({super.key, this.directItem});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contact & Delivery Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _paymentCategory = 'upi'; // 'upi', 'card', 'netbanking', 'cod'
  String _selectedUpiApp = 'gpay';
  final _vpaController = TextEditingController();

  final _cardHolderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  String _selectedBank = 'HDFC Bank';
  bool _isProcessingPayment = false;

  final List<Map<String, String>> _upiApps = [
    {'id': 'gpay', 'name': 'Google Pay', 'icon': '🌀', 'vpa': 'beebeeyond@okaxis', 'package': 'com.google.android.apps.nbu.paisa.user'},
    {'id': 'phonepe', 'name': 'PhonePe', 'icon': '🟣', 'vpa': 'beebeeyond@ybl', 'package': 'com.phonepe.app'},
    {'id': 'paytm', 'name': 'Paytm UPI', 'icon': '🔵', 'vpa': 'beebeeyond@paytm', 'package': 'net.one97.paytm'},
    {'id': 'bhim', 'name': 'BHIM UPI', 'icon': '🇮🇳', 'vpa': 'beebeeyond@upi', 'package': 'in.org.npci.upiapp'},
    {'id': 'cred', 'name': 'CRED UPI', 'icon': '⚡', 'vpa': 'beebeeyond@cred', 'package': 'com.dreamplug.androidapp'},
    {'id': 'custom', 'name': 'Enter UPI ID / VPA', 'icon': '⚡', 'vpa': '', 'package': ''},
  ];

  final List<String> _popularBanks = [
    'HDFC Bank',
    'State Bank of India (SBI)',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
  ];

  RazorpayService? _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentUser = ref.read(authStateProvider).user;
        if (currentUser != null) {
          if (currentUser.name.isNotEmpty) _nameController.text = currentUser.name;
          if (currentUser.email.isNotEmpty) _emailController.text = currentUser.email;
          if (currentUser.phone.isNotEmpty) _phoneController.text = currentUser.phone;
        }
      }
    });
  }

  @override
  void dispose() {
    _razorpayService?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _vpaController.dispose();
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  List<CartItemEntity> get _checkoutItems {
    if (widget.directItem != null) {
      return [widget.directItem!];
    }
    return ref.read(cartManagerProvider).value ?? [];
  }

  void _onProcessCheckout() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required shipping & payment fields correctly.')),
      );
      return;
    }

    final items = _checkoutItems;
    final totalPayable = items.totalPayable;

    setState(() => _isProcessingPayment = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
              SizedBox(height: 20),
              Text(
                'Creating Secure Server Order...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
              ),
              SizedBox(height: 6),
              Text(
                'Communicating with Bee Beyonnd backend & Razorpay...',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);

      // 1. Send product_id and quantity to create_order.php
      final serverOrder = await paymentRepo.createServerOrder(
        amount: totalPayable,
        currency: 'INR',
        receiptId: 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
        items: items.map((i) => {
          'product_id': i.id is int ? i.id : (int.tryParse('${i.id}') ?? 1),
          'quantity': i.quantity,
        }).toList(),
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog
      }

      // 2. Set up Razorpay callbacks
      _razorpayService?.onSuccess = (response) async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                  SizedBox(height: 20),
                  Text(
                    'Verifying Payment with Server...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        );

        try {
          final verification = await paymentRepo.verifyPaymentSignature(
            paymentId: response.paymentId ?? '',
            orderId: response.orderId ?? serverOrder.gatewayOrderId,
            signature: response.signature ?? '',
          );

          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop(); // Dismiss verification loading
            setState(() => _isProcessingPayment = false);

            if (verification.isVerified) {
              _completeOrderAndGenerateReceipt(
                'Razorpay Gateway',
                totalPayable,
                items,
                serverOrderId: serverOrder.orderId,
                serverReceiptId: 'REC-2025-${serverOrder.localOrderId.toString().padLeft(4, '0')}',
              );
            } else {
              AppAlertManager.showFloatingToast(
                context,
                title: 'Payment Verification Failed',
                message: verification.message ?? 'Server signature check failed.',
                icon: Icons.error_outline_rounded,
                backgroundColor: const Color(0xFF0F172A),
                accentColor: const Color(0xFFEF4444),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() => _isProcessingPayment = false);
            AppAlertManager.showFloatingToast(
              context,
              title: 'Verification Error',
              message: 'Could not verify payment: $e',
              icon: Icons.error_outline_rounded,
              backgroundColor: const Color(0xFF0F172A),
              accentColor: const Color(0xFFEF4444),
            );
          }
        }
      };

      _razorpayService?.onError = (response) {
        setState(() => _isProcessingPayment = false);

        final failureResp = response is PaymentFailureResponse ? response : null;
        final int? code = failureResp?.code;
        final String? msg = failureResp?.message;

        final isCancelled = code == Razorpay.PAYMENT_CANCELLED ||
            (msg?.toLowerCase().contains('cancel') ?? false) ||
            (msg?.toLowerCase().contains('dismiss') ?? false) ||
            (msg?.toLowerCase().contains('back') ?? false);

        AppAlertManager.showFloatingToast(
          context,
          title: isCancelled ? 'Payment Cancelled' : 'Payment Failed',
          message: isCancelled
              ? 'You cancelled the payment. Your order is saved as pending in My Orders.'
              : (msg ?? 'Transaction was declined or failed.'),
          icon: isCancelled ? Icons.info_outline_rounded : Icons.error_outline_rounded,
          backgroundColor: const Color(0xFF0F172A),
          accentColor: isCancelled ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
          actionLabel: 'VIEW ORDERS',
          onAction: () {
            context.push(RoutePaths.orders);
          },
        );

        if (isCancelled) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              context.go(RoutePaths.orders);
            }
          });
        }
      };

      // 3. Open Real Razorpay Checkout SDK
      _razorpayService?.openCheckout(
        keyId: serverOrder.keyId,
        amountPaise: serverOrder.amountPaise,
        gatewayOrderId: serverOrder.gatewayOrderId,
        name: 'Bee Beyonnd',
        description: 'Product Order #${serverOrder.orderId}',
        contact: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        customerName: _nameController.text.trim(),
      );

    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
        setState(() => _isProcessingPayment = false);
        AppAlertManager.showFloatingToast(
          context,
          title: 'Order Creation Error',
          message: '$e',
          icon: Icons.error_outline_rounded,
          backgroundColor: const Color(0xFF0F172A),
          accentColor: const Color(0xFFEF4444),
        );
      }
    }
  }

  void _completeOrderAndGenerateReceipt(
    String paymentMethod,
    double totalAmount,
    List<CartItemEntity> items, {
    String? serverOrderId,
    String? serverReceiptId,
  }) {
    final orderId = serverOrderId ?? 'ORD-${100000 + DateTime.now().millisecond * 888}';
    final receiptId = serverReceiptId ?? 'REC-2025-${(5000 + (orderId.hashCode % 4999)).abs()}';

    final subtotal = items.subtotal;
    final addressStr =
        '${_streetController.text.trim()}, ${_cityController.text.trim()} - ${_pincodeController.text.trim()}';

    final receiptItems = items.isEmpty
        ? [ReceiptItem(name: 'Bee Beeyond Order Items', quantity: 1, unitPrice: subtotal)]
        : items.map((i) => ReceiptItem(name: i.title, quantity: i.quantity, unitPrice: i.price)).toList();

    final newReceipt = ReceiptEntity(
      receiptId: receiptId,
      orderId: orderId,
      title: items.isNotEmpty ? items.first.title : 'Bee Beeyond Order',
      type: 'PRODUCT',
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerEmail: _emailController.text.trim(),
      deliveryAddress: addressStr,
      items: receiptItems,
      subtotal: subtotal,
      paymentMethod: paymentMethod,
      date: DateTime.now(),
    );

    ref.read(receiptsProvider.notifier).addReceipt(newReceipt);

    // Clear cart ONLY if checking out from saved cart (not direct buy now item)
    if (widget.directItem == null) {
      ref.read(cartManagerProvider.notifier).clearCart();
    }

    ref.read(notificationsProvider.notifier).postNotification(
      title: '📦 Order Confirmed & Paid!',
      message: 'Official 18% GST Tax Invoice ($receiptId) generated for ${newReceipt.title}.',
      category: 'orders',
    );

    AppAlertManager.showFloatingToast(
      context,
      title: 'Order Confirmed & Paid!',
      message: 'Official tax invoice ($receiptId.pdf) generated successfully.',
      icon: Icons.task_alt_rounded,
      backgroundColor: const Color(0xFF0F172A),
      accentColor: const Color(0xFF10B981),
      actionLabel: 'VIEW INVOICE',
      onAction: () {
        context.push(
          RoutePaths.receiptPreview,
          extra: newReceipt,
        );
      },
    );

    context.push(
      RoutePaths.receiptPreview,
      extra: newReceipt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedCartItems = ref.watch(cartManagerProvider).value ?? [];
    final cartItems = widget.directItem != null ? [widget.directItem!] : savedCartItems;

    final subtotal = cartItems.subtotal;
    final tax = cartItems.taxAmount;
    final totalPayable = cartItems.totalPayable;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Express Checkout & Payment'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VIP CHECKOUT BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F0C20), Color(0xFF1E1B4B), Color(0xFF312E81)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x300F0C20), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AssetPaths.beeBeyondImage1,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.security_rounded, color: Colors.amberAccent, size: 36),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEE BEEYOND',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Secured 256-Bit SSL Encrypted Checkout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Guaranteed safe transaction & genuine products',
                            style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 1: SHIPPING ADDRESS & CONTACT
              _buildSectionCard(
                title: 'Shipping & Delivery Address',
                icon: Icons.local_shipping_outlined,
                iconColor: const Color(0xFF6366F1),
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name *',
                    hint: 'e.g. Aarav Sharma',
                    validator: PaymentValidators.validateCardHolderName,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number *',
                          hint: '9876543210',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                          validator: PaymentValidators.validateIndianPhone,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _emailController,
                          label: 'Email Address *',
                          hint: 'aarav@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim()) ? 'Valid Email required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _streetController,
                    label: 'Flat / House / Building Address *',
                    hint: 'e.g. Flat 302, Green Heights, MG Road',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Building address required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City / Town *',
                          hint: 'e.g. Mumbai / Delhi',
                          validator: (v) => v == null || v.trim().isEmpty ? 'City required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _pincodeController,
                          label: 'PIN Code *',
                          hint: 'e.g. 400001',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                          validator: PaymentValidators.validateIndianPincode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SECTION 2: PAYMENT METHOD SELECTION
              _buildSectionCard(
                title: 'Select Payment Option',
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFF10B981),
                children: [
                  // Payment Option Radio Tabs
                  _buildPaymentCategoryOption(
                    id: 'upi',
                    title: 'UPI / Instant Mobile Payments',
                    subtitle: 'Google Pay, PhonePe, Paytm, BHIM VPA',
                    icon: Icons.vibration_rounded,
                  ),
                  _buildPaymentCategoryOption(
                    id: 'card',
                    title: 'Credit / Debit Card',
                    subtitle: 'Visa, Mastercard, RuPay, Maestro',
                    icon: Icons.credit_card_rounded,
                  ),
                  _buildPaymentCategoryOption(
                    id: 'netbanking',
                    title: 'NetBanking Portal',
                    subtitle: 'All Major Indian Banks Supported',
                    icon: Icons.account_balance_rounded,
                  ),
                  _buildPaymentCategoryOption(
                    id: 'cod',
                    title: 'Cash / Pay on Delivery',
                    subtitle: 'Pay at your doorstep upon arrival',
                    icon: Icons.handshake_rounded,
                  ),

                  const Divider(height: 24, color: Color(0xFFCBD5E1)),

                  // SUB-DETAILS ACCORDING TO SELECTED CATEGORY
                  if (_paymentCategory == 'upi') ...[
                    const Text('Select Preferred UPI App:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _upiApps.map((app) {
                        final isSelected = _selectedUpiApp == app['id'];
                        return ChoiceChip(
                          selected: isSelected,
                          selectedColor: const Color(0xFFEEF2FF),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFCBD5E1), width: isSelected ? 1.8 : 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(app['icon']!, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(app['name']!, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? const Color(0xFF312E81) : AppColors.textPrimary)),
                            ],
                          ),
                          onSelected: (_) => setState(() => _selectedUpiApp = app['id']!),
                        );
                      }).toList(),
                    ),
                    if (_selectedUpiApp == 'custom') ...[
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _vpaController,
                        label: 'Virtual Payment Address (VPA / UPI ID)',
                        hint: 'username@okaxis or mobile@paytm',
                        validator: PaymentValidators.validateUpiId,
                      ),
                    ],
                  ] else if (_paymentCategory == 'card') ...[
                    _buildTextField(
                      controller: _cardHolderNameController,
                      label: 'Cardholder Name *',
                      hint: 'e.g. AARAV SHARMA',
                      textCapitalization: TextCapitalization.characters,
                      validator: PaymentValidators.validateCardHolderName,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _cardNumberController,
                      label: 'Card Number (Luhn Verified) *',
                      hint: '4532 8910 1234 5678',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CardNumberInputFormatter(),
                        LengthLimitingTextInputFormatter(19),
                      ],
                      validator: PaymentValidators.validateCardNumber,
                      suffixIcon: UnconstrainedBox(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            PaymentValidators.detectCardNetwork(_cardNumberController.text),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cardExpiryController,
                            label: 'Expiry (MM/YY) *',
                            hint: '12/28',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CardExpiryInputFormatter(),
                              LengthLimitingTextInputFormatter(5),
                            ],
                            validator: PaymentValidators.validateExpiryDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _cardCvvController,
                            label: 'CVV / CVC *',
                            hint: '123',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (v) => PaymentValidators.validateCVV(
                              v,
                              isAmex: _cardNumberController.text.startsWith('34') ||
                                  _cardNumberController.text.startsWith('37'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_paymentCategory == 'netbanking') ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBank,
                      decoration: InputDecoration(
                        labelText: 'Select NetBanking Bank',
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      ),
                      items: _popularBanks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                      onChanged: (v) => setState(() => _selectedBank = v!),
                    ),
                  ] else if (_paymentCategory == 'cod') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cash on delivery is available for eligible pin codes. Please keep exact cash ready.',
                              style: TextStyle(color: Color(0xFFB45309), fontSize: 11.5, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // SECTION 3: ORDER ITEMS & PRICE BREAKDOWN
              _buildSectionCard(
                title: 'Order Summary',
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF7C3AED),
                children: [
                  if (cartItems.isNotEmpty)
                    ...cartItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
                    const Text('1x Bee Beeyond Healing Product Order', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),

                  const Divider(height: 20, color: AppColors.divider),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Items Subtotal:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(CurrencyUtils.formatINR(subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Taxes & Gateway Fees (3%):', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(CurrencyUtils.formatINR(tax), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery Charges:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('FREE', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total Payable:', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(CurrencyUtils.formatINR(totalPayable), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 19)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // SUBMIT ORDER BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isProcessingPayment ? null : _onProcessCheckout,
                  child: _isProcessingPayment
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, color: Colors.amberAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'PAY ${CurrencyUtils.formatINR(totalPayable)} SECURELY',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPaymentCategoryOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentCategory == id;
    return InkWell(
      onTap: () => setState(() => _paymentCategory = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0), width: isSelected ? 1.6 : 1.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? AppColors.primary : const Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderSubtle)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
      ),
    );
  }
}

// UPI SIMULATION MODAL BOTTOM SHEET
class _UpiSimulationModal extends StatelessWidget {
  final String appName;
  final String upiId;
  final double amount;
  final String upiUriString;
  final VoidCallback onSuccess;

  const _UpiSimulationModal({
    required this.appName,
    required this.upiId,
    required this.amount,
    required this.upiUriString,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
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
            const Text('BEE BEEYOND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.amber, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text('Paying via $appName', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
              child: Text('VPA ID: $upiId', style: const TextStyle(color: Color(0xFF059669), fontSize: 11.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Text(CurrencyUtils.formatINR(amount), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: onSuccess,
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: const Text('SIMULATE SUCCESSFUL PAYMENT ✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel Transaction', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
