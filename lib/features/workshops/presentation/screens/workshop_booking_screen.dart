import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/workshop_booking_storage.dart';
import '../providers/workshop_provider.dart';

enum WorkshopBookingViewState {
  form,
  success,
  pending,
  failed,
  refundReview,
}

class WorkshopBookingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? workshopData;

  const WorkshopBookingScreen({
    super.key,
    this.workshopData,
  });

  @override
  ConsumerState<WorkshopBookingScreen> createState() => _WorkshopBookingScreenState();
}

class _WorkshopBookingScreenState extends ConsumerState<WorkshopBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  final _bookingStorage = WorkshopBookingStorage();
  Razorpay? _razorpay;

  WorkshopBookingViewState _viewState = WorkshopBookingViewState.form;

  bool _isProcessing = false;
  String _processingMessage = 'Processing...';

  int? _currentWorkshopOrderId;
  String? _currentRazorpayOrderId;
  String? _lastPaymentSignature;
  String? _confirmedBookingNumber;
  String? _paymentId;
  String? _statusMessage;

  late double _basePrice;
  late double _discount;
  double? _authoritativePayableAmount;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    _setupInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndRecoverPendingBooking();
    });
  }

  void _setupInitialData() {
    final rawBase = widget.workshopData?['basePrice'] ?? widget.workshopData?['price'] ?? widget.workshopData?['base_price'];
    final rawDiscount = widget.workshopData?['discount'];

    _basePrice = double.tryParse(rawBase?.toString() ?? '1499') ?? 1499.0;
    _discount = double.tryParse(rawDiscount?.toString() ?? '0') ?? 0.0;
  }

  Future<void> _checkAuthAndRecoverPendingBooking() async {
    final authState = ref.read(authStateProvider);
    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to book a masterclass.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.push(RoutePaths.login);
      }
      return;
    }

    final user = authState.user!;
    if (_nameController.text.isEmpty) _nameController.text = user.name;
    if (_emailController.text.isEmpty) _emailController.text = user.email;
    if (_phoneController.text.isEmpty) _phoneController.text = user.phone;

    final rawId = widget.workshopData?['id'] ?? widget.workshopData?['workshop_id'];
    final int workshopId = int.tryParse(rawId?.toString() ?? '') ?? 0;

    if (workshopId <= 0) return;

    final pendingData = await _bookingStorage.getPendingBooking(workshopId);
    if (pendingData != null && pendingData['workshop_order_id'] != null) {
      final orderId = (pendingData['workshop_order_id'] as num).toInt();
      final rzpOrderId = pendingData['razorpay_order_id']?.toString() ?? '';
      final pId = pendingData['razorpay_payment_id']?.toString() ?? '';
      final sig = pendingData['razorpay_signature']?.toString() ?? '';
      final amt = (pendingData['amount'] as num?)?.toDouble();

      setState(() {
        _currentWorkshopOrderId = orderId;
        _currentRazorpayOrderId = rzpOrderId;
        _paymentId = pId.isNotEmpty ? pId : null;
        _lastPaymentSignature = sig.isNotEmpty ? sig : null;
        if (amt != null && amt > 0) {
          _authoritativePayableAmount = amt / 100.0;
        }
        _isProcessing = true;
        _processingMessage = 'Checking existing booking status...';
      });

      await _verifyExistingOrder(
        orderId: orderId,
        paymentId: pId,
        razorpayOrderId: rzpOrderId,
        signature: sig,
        workshopId: workshopId,
      );
    }
  }

  Future<void> _verifyExistingOrder({
    required int orderId,
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
    required int workshopId,
  }) async {
    try {
      final repository = ref.read(workshopRepositoryProvider);
      final verifyResult = paymentId.isNotEmpty
          ? await repository.verifyWorkshopPayment(
              workshopOrderId: orderId,
              razorpayPaymentId: paymentId,
              razorpayOrderId: razorpayOrderId,
              razorpaySignature: signature,
            )
          : await repository.getWorkshopOrderStatus(
              workshopOrderId: orderId,
            );

      if (!mounted) return;

      if (verifyResult.isConfirmed) {
        await _bookingStorage.clearPendingBooking(workshopId);
        setState(() {
          _isProcessing = false;
          _viewState = WorkshopBookingViewState.success;
          _confirmedBookingNumber = verifyResult.bookingNumber.isNotEmpty
              ? verifyResult.bookingNumber
              : 'WS-$orderId';
        });
      } else if (verifyResult.isDefinitivelyFailed) {
        await _bookingStorage.clearPendingBooking(workshopId);
        setState(() {
          _isProcessing = false;
          _viewState = WorkshopBookingViewState.failed;
          _statusMessage = verifyResult.message.isNotEmpty
              ? verifyResult.message
              : 'Payment was not completed or failed permanently.';
        });
      } else if (verifyResult.isRefundReview) {
        setState(() {
          _isProcessing = false;
          _viewState = WorkshopBookingViewState.refundReview;
          _statusMessage = verifyResult.message.isNotEmpty
              ? verifyResult.message
              : 'Your payment was captured, but registration requires manual review. Please contact support.';
        });
      } else {
        // Pending or Network Error -> Keep on Pending Status Screen with Retry
        setState(() {
          _isProcessing = false;
          _viewState = WorkshopBookingViewState.pending;
          _statusMessage = verifyResult.message.isNotEmpty
              ? verifyResult.message
              : 'Payment recorded, but status verification is pending due to connection delays.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _viewState = WorkshopBookingViewState.pending;
          _statusMessage = 'Network error checking existing booking: $e';
        });
      }
    }
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _finalAmount {
    if (_authoritativePayableAmount != null && _authoritativePayableAmount! > 0) {
      return _authoritativePayableAmount!;
    }
    final net = _basePrice - _discount;
    return net > 0 ? net : 0.0;
  }

  Future<void> _startPaymentFlow() async {
    if (_isProcessing) return;

    if (_viewState == WorkshopBookingViewState.pending ||
        _viewState == WorkshopBookingViewState.refundReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have an unresolved payment. Please complete status verification before starting a new booking.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authState = ref.read(authStateProvider);
    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to proceed with booking.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.push(RoutePaths.login);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final rawId = widget.workshopData?['id'] ?? widget.workshopData?['workshop_id'];
    final int workshopId = int.tryParse(rawId?.toString() ?? '') ?? 0;

    if (workshopId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid workshop selected. Please try selecting the workshop again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Creating workshop order...';
    });

    try {
      final repository = ref.read(workshopRepositoryProvider);
      final orderResult = await repository.createWorkshopOrder(
        workshopId: workshopId,
        attendeeName: _nameController.text.trim(),
        attendeeEmail: _emailController.text.trim(),
        attendeePhone: _phoneController.text.trim(),
        specialNote: _notesController.text.trim(),
      );

      if (!mounted) return;

      if (!orderResult.success || orderResult.razorpayOrderId.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderResult.message.isNotEmpty ? orderResult.message : 'Could not create booking order. Please try again.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      _currentWorkshopOrderId = orderResult.workshopOrderId;
      _currentRazorpayOrderId = orderResult.razorpayOrderId;

      if (orderResult.amount > 0) {
        setState(() {
          _authoritativePayableAmount = orderResult.amount / 100.0;
        });
      }

      await _bookingStorage.savePendingBooking(
        workshopId: workshopId,
        workshopOrderId: orderResult.workshopOrderId,
        razorpayOrderId: orderResult.razorpayOrderId,
        amount: orderResult.amount.toDouble(),
        attendeeName: _nameController.text.trim(),
      );

      final title = widget.workshopData?['title'] ?? 'Masterclass Booking';

      final options = {
        'key': orderResult.razorpayKeyId,
        'amount': orderResult.amount,
        'order_id': orderResult.razorpayOrderId,
        'currency': orderResult.currency.isNotEmpty ? orderResult.currency : 'INR',
        'name': 'Bee Beyonnd Wellness',
        'description': 'Booking for $title',
        'prefill': {
          'contact': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
        },
        'theme': {
          'color': '#312E81',
        }
      };

      try {
        _razorpay?.open(options);
      } catch (e) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open payment Gateway: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    _paymentId = response.paymentId;
    _lastPaymentSignature = response.signature;
    if (response.orderId != null && response.orderId!.isNotEmpty) {
      _currentRazorpayOrderId = response.orderId;
    }

    final rawId = widget.workshopData?['id'] ?? widget.workshopData?['workshop_id'];
    final int workshopId = int.tryParse(rawId?.toString() ?? '') ?? 0;

    if (workshopId > 0 && _currentWorkshopOrderId != null) {
      await _bookingStorage.savePendingBooking(
        workshopId: workshopId,
        workshopOrderId: _currentWorkshopOrderId!,
        razorpayOrderId: _currentRazorpayOrderId ?? '',
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
        amount: (_finalAmount * 100),
        attendeeName: _nameController.text.trim(),
      );
    }

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Verifying payment with server...';
    });

    final orderIdToVerify = _currentWorkshopOrderId;
    if (orderIdToVerify == null || orderIdToVerify == 0) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to verify payment: missing order reference.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await _verifyExistingOrder(
      orderId: orderIdToVerify,
      paymentId: response.paymentId ?? '',
      razorpayOrderId: response.orderId ?? _currentRazorpayOrderId ?? '',
      signature: response.signature ?? '',
      workshopId: workshopId,
    );
  }

  Future<void> _retryVerification() async {
    if (_isProcessing) return;

    final orderIdToVerify = _currentWorkshopOrderId;
    final rawId = widget.workshopData?['id'] ?? widget.workshopData?['workshop_id'];
    final int workshopId = int.tryParse(rawId?.toString() ?? '') ?? 0;

    if (orderIdToVerify == null || orderIdToVerify == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing order details to retry verification.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Retrying payment verification...';
    });

    await _verifyExistingOrder(
      orderId: orderIdToVerify,
      paymentId: _paymentId ?? '',
      razorpayOrderId: _currentRazorpayOrderId ?? '',
      signature: _lastPaymentSignature ?? '',
      workshopId: workshopId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? "Transaction Cancelled"}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _resetToNewBooking() async {
    final rawId = widget.workshopData?['id'] ?? widget.workshopData?['workshop_id'];
    final int workshopId = int.tryParse(rawId?.toString() ?? '') ?? 0;
    if (workshopId > 0) {
      await _bookingStorage.clearPendingBooking(workshopId);
    }
    setState(() {
      _viewState = WorkshopBookingViewState.form;
      _currentWorkshopOrderId = null;
      _currentRazorpayOrderId = null;
      _paymentId = null;
      _lastPaymentSignature = null;
      _statusMessage = null;
      _authoritativePayableAmount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_viewState) {
      case WorkshopBookingViewState.success:
        return _buildSuccessScreen();
      case WorkshopBookingViewState.failed:
        return _buildDefinitivelyFailedScreen();
      case WorkshopBookingViewState.refundReview:
        return _buildRefundReviewScreen();
      case WorkshopBookingViewState.pending:
        return _buildPendingVerificationScreen();
      case WorkshopBookingViewState.form:
      default:
        return _buildFormScreen();
    }
  }

  Widget _buildFormScreen() {
    final title = widget.workshopData?['title'] ?? 'Certified Masterclass';
    final instructor = widget.workshopData?['instructor'] ?? 'Acharya Devraj';
    final image = widget.workshopData?['thumbnailUrl'] ?? widget.workshopData?['image'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Book Masterclass'),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWorkshopSummaryCard(title, instructor, image),
                        const SizedBox(height: 20),
                        Text(
                          'Attendee Information',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person_outline_rounded,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'Enter your email for pass receipt',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone / WhatsApp Number',
                          hint: 'Enter contact number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val == null || val.trim().length < 10 ? 'Valid phone number required' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _notesController,
                          label: 'Special Note / Question (Optional)',
                          hint: 'Anything you wish to ask mentor beforehand',
                          icon: Icons.chat_bubble_outline_rounded,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        _buildPriceBreakdownCard(),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _startPaymentFlow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _processingMessage,
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        : Text(
                            'Proceed to Pay ${CurrencyUtils.formatINR(_finalAmount)}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (_isProcessing)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkshopSummaryCard(String title, String instructor, String image) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image.isNotEmpty && image.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFF1E1B4B),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFF1E1B4B),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 36),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: const Color(0xFF1E1B4B),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 36),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mentor: $instructor',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          _buildSummaryLine('Base Tuition Fee', CurrencyUtils.formatINR(_basePrice)),
          if (_discount > 0 && _authoritativePayableAmount == null) ...[
            const SizedBox(height: 6),
            _buildSummaryLine('Special Discount Offer', '-${CurrencyUtils.formatINR(_discount)}', isDiscount: true),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Payable Amount',
                    style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  if (_authoritativePayableAmount != null)
                    Text(
                      'Verified by backend order',
                      style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              Text(
                CurrencyUtils.formatINR(_finalAmount),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDiscount ? const Color(0xFF10B981) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 72),
              ),
              const SizedBox(height: 20),
              Text(
                'Masterclass Seat Confirmed!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              if (_confirmedBookingNumber != null && _confirmedBookingNumber!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Booking #: $_confirmedBookingNumber',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
              if (_paymentId != null && _paymentId!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Payment ID: $_paymentId',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Thank you for enrolling. Access instructions and calendar invite have been dispatched to your email.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.go(RoutePaths.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Back to Home', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingVerificationScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFBEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 72),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Verification Pending',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              if (_currentWorkshopOrderId != null && _currentWorkshopOrderId! > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Order ID: #$_currentWorkshopOrderId',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
              if (_paymentId != null && _paymentId!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Payment ID: $_paymentId',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                _statusMessage ??
                    'Your payment was processed, but server verification is taking longer than expected. Tap Retry Verification to check the latest status.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _retryVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  _isProcessing ? _processingMessage : 'Retry Verification',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  context.push(RoutePaths.support);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Contact Support', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.go(RoutePaths.home);
                },
                child: Text('Back to Home', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefundReviewScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: Color(0xFF3B82F6), size: 72),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Under Review',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              if (_currentWorkshopOrderId != null && _currentWorkshopOrderId! > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Order ID: #$_currentWorkshopOrderId',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
              if (_paymentId != null && _paymentId!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Payment ID: $_paymentId',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                _statusMessage ??
                    'Your payment was received, but the registration is under manual review or refund processing. Please contact support before starting another booking.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.push(RoutePaths.support);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.support_agent_rounded, size: 20),
                label: Text('Contact Support Team', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  context.go(RoutePaths.home);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Back to Home', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefinitivelyFailedScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 72),
              ),
              const SizedBox(height: 20),
              Text(
                'Booking Unsuccessful',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              if (_currentWorkshopOrderId != null && _currentWorkshopOrderId! > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Order ID: #$_currentWorkshopOrderId',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                _statusMessage ??
                    'Payment was cancelled or failed permanently. You may attempt a new booking.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _resetToNewBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text('Start New Booking', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  context.go(RoutePaths.home);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Back to Home', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
