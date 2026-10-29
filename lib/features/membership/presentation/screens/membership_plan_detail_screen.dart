import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'membership_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/razorpay_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/status_dialog.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/membership_plan_entity.dart';
import 'package:intl/intl.dart';
import '../providers/expiry_provider.dart';
import '../providers/membership_provider.dart';

class MembershipPlanDetailScreen extends ConsumerStatefulWidget {
  final String planId;
  final MembershipPlanEntity? initialPlan;

  const MembershipPlanDetailScreen({
    super.key,
    required this.planId,
    this.initialPlan,
  });

  @override
  ConsumerState<MembershipPlanDetailScreen> createState() =>
      _MembershipPlanDetailScreenState();
}

enum BillingPeriod { monthly, yearly }

class _MembershipPlanDetailScreenState
    extends ConsumerState<MembershipPlanDetailScreen> {
  BillingPeriod _selectedBillingPeriod = BillingPeriod.yearly;
  RazorpayService? _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
  }

  @override
  void dispose() {
    _razorpayService?.dispose();
    super.dispose();
  }

  void _openCheckoutScreen(MembershipPlanEntity plan) {
    if (_selectedBillingPeriod == BillingPeriod.monthly) {
      _showMonthlyCheckoutSheet(plan);
    } else {
      _showYearlyCheckoutSheet(plan);
    }
  }

  void _processRazorpayPayment(
    MembershipPlanEntity plan,
    double price,
    String billingLabel,
  ) async {
    final activePass = ref.read(activePassProvider);
    if (activePass != null && activePass.isMatchingPlanActive(plan.id, plan.slug)) {
      StatusDialog.show(
        context,
        title: 'Plan Already Active! 👑',
        description: 'You are currently subscribed to ${activePass.passName}.\nValid until: ${DateFormat('dd MMM yyyy, hh:mm a').format(activePass.expiresAt)}.\n\nYou do not need to purchase this plan again while active.',
        isSuccess: false,
        onAction: () {},
        actionText: 'OK',
      );
      return;
    }

    final billingPeriodStr =
        _selectedBillingPeriod == BillingPeriod.monthly ? 'month' : 'year';

    final currentUser = ref.read(authStateProvider).user;
    final customerName = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'Bee Beyonnd VIP';
    final customerPhone = currentUser?.phone.isNotEmpty == true ? currentUser!.phone : '9876543210';
    final customerEmail = currentUser?.email.isNotEmpty == true ? currentUser!.email : 'vip@beebeyonnd.com';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final repo = ref.read(membershipRepositoryProvider);
      final planIdInt = int.tryParse(plan.id) ?? 1;

      // 1. Call membership_create_order.php API with plan_id & billing_period
      final orderResponse = await repo.createMembershipOrder(
        planId: planIdInt,
        billingPeriod: billingPeriodStr,
      );

      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
      }

      if (orderResponse == null || !orderResponse.success || orderResponse.razorpayOrderId.isEmpty) {
        if (mounted) {
          StatusDialog.show(
            context,
            title: 'Membership Order Creation Failed',
            description: orderResponse?.message ?? 'Unable to create membership order. Please try again.',
            isSuccess: false,
            onAction: () {},
            actionText: 'OK',
          );
        }
        return;
      }

      // 2. Setup Razorpay callbacks
      _razorpayService?.onSuccess = (response) async {
        if (!mounted) return;

        final paymentId = response.paymentId ?? '';
        final orderId = response.orderId ?? orderResponse.razorpayOrderId;
        final signature = response.signature ?? '';

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );

        final repo = ref.read(membershipRepositoryProvider);
        final isVerified = await repo.verifyMembershipPayment(
          membershipOrderId: orderResponse.membershipOrderId,
          razorpayPaymentId: paymentId,
          razorpayOrderId: orderId,
          razorpaySignature: signature,
        );

        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
        }

        if (!mounted) return;

        if (isVerified) {
          // Immediately activate the pass in local state & SharedPreferences
          await ref.read(activePassProvider.notifier).activatePass(
            passId: plan.id,
            passName: '${plan.name} Membership Pass',
            slug: plan.slug,
            durationYears: plan.accessDuration > 0 ? plan.accessDuration : 1,
            amountPaid: plan.price,
            transactionId: paymentId,
          );

          StatusDialog.show(
            context,
            title: 'Membership Activated! 👑',
            description:
                'Payment ID: $paymentId\nOrder ID: $orderId\n\nYour ${plan.name} Membership Pass has been successfully activated!',
            isSuccess: true,
            onAction: () {
              context.go(RoutePaths.membership);
            },
            actionText: 'View My Pass',
          );
        } else {
          // Verification failed or pending — NEVER display success message
          StatusDialog.show(
            context,
            title: 'Verification Pending ⏳',
            description:
                'Payment ID: $paymentId\nOrder ID: $orderId\n\nYour payment was received by Razorpay, but automatic verification is pending.\n\nPlease do NOT pay again. Check your membership status in a few moments or contact support with your Payment ID.',
            isSuccess: false,
            onAction: () {
              context.go(RoutePaths.membership);
            },
            actionText: 'Check Membership Status',
          );
        }
      };

      _razorpayService?.onError = (response) {
        if (!mounted) return;

        final code = response.code;
        final msg = response.message;

        final isDismissed = code == Razorpay.PAYMENT_CANCELLED ||
            (msg?.toLowerCase().contains('cancel') ?? false) ||
            (msg?.toLowerCase().contains('dismiss') ?? false) ||
            (msg?.toLowerCase().contains('back') ?? false);

        StatusDialog.show(
          context,
          title: isDismissed ? 'Checkout Cancelled' : 'Payment Failed',
          description: isDismissed
              ? 'Membership checkout was dismissed or cancelled. No amount was debited.'
              : (msg ?? 'Transaction declined. Please try again.'),
          isSuccess: false,
          onAction: () {},
          actionText: 'OK',
        );
      };

      // 3. Open Razorpay Checkout using returned order parameters
      _razorpayService?.openCheckout(
        keyId: orderResponse.razorpayKeyId,
        amountPaise: orderResponse.amountPaise,
        gatewayOrderId: orderResponse.razorpayOrderId,
        name: 'Bee Beyonnd',
        description: '${plan.displayName} ($billingLabel)',
        contact: customerPhone,
        email: customerEmail,
        customerName: customerName,
      );
    } catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        AppAlertManager.showFloatingToast(
          context,
          title: 'Membership Order Error',
          message: '$e',
          icon: Icons.error_outline_rounded,
          backgroundColor: const Color(0xFF0F172A),
          accentColor: const Color(0xFFEF4444),
        );
      }
    }
  }

  void _showMonthlyCheckoutSheet(MembershipPlanEntity plan) {
    final price = plan.monthlyPrice > 0 ? plan.monthlyPrice : 199.0;
    final formattedPrice = CurrencyUtils.formatINR(price);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MONTHLY VIP PASS',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6845C4),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '${plan.displayName} (Monthly)',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Flexible monthly subscription with full VIP perks',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),

            const Divider(height: 24, color: Color(0xFFE2E8F0)),

            // Price Breakdown Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Billing Plan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      Text(
                        '$formattedPrice / Month',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF6845C4),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recurring Auto-Renew', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                      Text('Monthly Cycle', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Taxes & Charges', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                      Text('Included', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _processRazorpayPayment(plan, price, 'Monthly Pass');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6845C4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pay $formattedPrice Monthly →',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showYearlyCheckoutSheet(MembershipPlanEntity plan) {
    final price = plan.annualPrice > 0 ? plan.annualPrice : 1999.0;
    final formattedPrice = CurrencyUtils.formatINR(price);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🌟 ANNUAL VIP PASS (BEST VALUE)',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '${plan.displayName} (Annual)',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '365 Days Uninterrupted VIP Access with Maximum Savings',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 14),

            // Savings Highlight Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFF059669), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Annual Savings: ₹389 (16.3% OFF) vs monthly billing',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24, color: Color(0xFFE2E8F0)),

            // Price Breakdown Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Annual Subscription',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      Text(
                        '$formattedPrice / Year',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Access Validity', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                      Text('1 Year (365 Days)', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Taxes & Gateway Fees', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                      Text('Included', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _processRazorpayPayment(plan, price, 'Annual Pass');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pay $formattedPrice Annually →',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(membershipPlanDetailProvider(widget.planId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: widget.initialPlan?.displayName ?? 'VIP Membership Details',
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(membershipPlanDetailProvider(widget.planId));
          ref.invalidate(membershipPlansProvider);
        },
        child: detailAsync.when(
          skipLoadingOnRefresh: true,
          data: (plan) {
            return _buildDetailContent(plan);
          },
          loading: () => widget.initialPlan != null
              ? _buildDetailContent(widget.initialPlan!)
              : const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
          error: (err, stack) => widget.initialPlan != null
              ? _buildDetailContent(widget.initialPlan!)
              : Center(
                  child: Text('Error loading details: $err'),
                ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(MembershipPlanEntity plan) {
    final defaultFeatures = [
      'Annual savings: 389rs (16.3%) compared with paying monthly for 12 months.',
      '• Access to selected digital books, PDFs, music and videos',
      '• 5% off eligible courses, workshops and paid services.',
      'Early notifications about new courses and workshops.',
    ];

    final featuresList = plan.features.isNotEmpty ? plan.features : defaultFeatures;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO BANNER CARD WITH 3D AUTO-FLIP & SHINING EFFECT
                _ShiningFlippablePlanBanner(plan: plan),

                const SizedBox(height: 16),

                // PLAN TITLE & TAGLINE
                Text(
                  plan.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.displayTagline,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: plan.cardThemeColor,
                  ),
                ),

                if (plan.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      plan.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // 2. BILLING PERIOD SELECTOR TABS (MONTHLY VS YEARLY)
                Text(
                  'SELECT BILLING PERIOD',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Monthly Option Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBillingPeriod = BillingPeriod.monthly;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedBillingPeriod == BillingPeriod.monthly
                                ? const Color(0xFFF3E8FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _selectedBillingPeriod == BillingPeriod.monthly
                                  ? const Color(0xFF6845C4)
                                  : const Color(0xFFE2E8F0),
                              width: _selectedBillingPeriod == BillingPeriod.monthly ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _selectedBillingPeriod == BillingPeriod.monthly
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    size: 18,
                                    color: _selectedBillingPeriod == BillingPeriod.monthly
                                        ? const Color(0xFF6845C4)
                                        : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Monthly',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyUtils.formatINR(plan.monthlyPrice),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF6845C4),
                                ),
                              ),
                              Text(
                                '/ Month',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Yearly Option Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBillingPeriod = BillingPeriod.yearly;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedBillingPeriod == BillingPeriod.yearly
                                ? const Color(0xFFECFDF5)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _selectedBillingPeriod == BillingPeriod.yearly
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFE2E8F0),
                              width: _selectedBillingPeriod == BillingPeriod.yearly ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _selectedBillingPeriod == BillingPeriod.yearly
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    size: 18,
                                    color: _selectedBillingPeriod == BillingPeriod.yearly
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Annual',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '16.3% OFF',
                                      style: GoogleFonts.poppins(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyUtils.formatINR(plan.annualPrice),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              Text(
                                '/ Year (Save ₹389)',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 3. FEATURES LIST
                Text(
                  'PLAN BENEFITS & PRIVILEGES',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: List.generate(featuresList.length, (index) {
                      final feat = featuresList[index];
                      final isSavings = feat.toLowerCase().contains('savings');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isSavings ? const Color(0xFFDCFCE7) : const Color(0xFFF3E8FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSavings ? Icons.auto_awesome_rounded : Icons.check_rounded,
                                size: 14,
                                color: isSavings ? const Color(0xFF059669) : const Color(0xFF6845C4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                feat,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: isSavings ? FontWeight.bold : FontWeight.w500,
                                  color: isSavings ? const Color(0xFF047857) : const Color(0xFF334155),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. INCLUDED DIGITAL VAULT ACCESS & SPECIFIC CONTENTS
                Text(
                  'INCLUDED DIGITAL VAULT ACCESS',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                if (plan.contents.isNotEmpty)
                  Column(
                    children: plan.contents.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: item.color.withValues(alpha: 0.25)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item.icon, size: 18, color: item.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.displayTitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Access: ${item.accessType.toUpperCase()} • ${item.contentType.toUpperCase()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'INCLUDED',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildContentChip(Icons.auto_stories_rounded, 'Selected E-Books & PDFs', const Color(0xFF059669)),
                      _buildContentChip(Icons.music_note_rounded, 'Binaural Music Tracks', const Color(0xFF6845C4)),
                      _buildContentChip(Icons.play_circle_rounded, 'Guided Video Lectures', const Color(0xFFD97706)),
                      _buildContentChip(Icons.school_rounded, '5% Course Discount', const Color(0xFF0288D1)),
                    ],
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // STICKY BOTTOM ACTION BAR
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedBillingPeriod == BillingPeriod.monthly
                        ? CurrencyUtils.formatINR(plan.monthlyPrice)
                        : CurrencyUtils.formatINR(plan.annualPrice),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    _selectedBillingPeriod == BillingPeriod.monthly ? 'Billed Monthly' : 'Save 16.3% Annually',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _selectedBillingPeriod == BillingPeriod.monthly ? const Color(0xFF6845C4) : const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ShiningSubscribeButton(
                  text: 'Subscribe Now →',
                  color: _selectedBillingPeriod == BillingPeriod.monthly
                      ? const Color(0xFF6845C4)
                      : const Color(0xFF059669),
                  onPressed: () => _openCheckoutScreen(plan),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// 3D AUTO-FLIPPABLE PLAN BANNER WITH PERIODIC SHINING GLINT
class _ShiningFlippablePlanBanner extends StatefulWidget {
  final MembershipPlanEntity plan;

  const _ShiningFlippablePlanBanner({
    required this.plan,
  });

  @override
  State<_ShiningFlippablePlanBanner> createState() =>
      __ShiningFlippablePlanBannerState();
}

class __ShiningFlippablePlanBannerState
    extends State<_ShiningFlippablePlanBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  Timer? _autoFlipTimer;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    _autoFlipTimer = Timer.periodic(const Duration(milliseconds: 5500), (_) {
      if (mounted) {
        _toggleFlip();
      }
    });
  }

  void _toggleFlip() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _autoFlipTimer?.cancel();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value;
          final isBackFacing = angle >= (math.pi / 2);

          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isBackFacing
                ? Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _buildBackFace(),
                  )
                : _buildFrontFace(),
          );
        },
      ),
    );
  }

  Widget _buildFrontFace() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.plan.cardLightBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.plan.cardThemeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.plan.cardThemeColor.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          ShiningImageWrapper(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: Image.asset(
                widget.plan.bannerAssetPath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: widget.plan.cardLightBg,
                    height: 220,
                    child: Center(
                      child: Icon(widget.plan.icon, size: 80, color: widget.plan.cardThemeColor),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, color: widget.plan.cardThemeColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.plan.displayBadgeText,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: widget.plan.cardThemeColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 12,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.threed_rotation_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to Flip 3D',
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackFace() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.plan.cardThemeColor,
            widget.plan.cardThemeColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.plan.cardThemeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.plan.icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            widget.plan.displayName,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            widget.plan.displayTagline,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.amberAccent,
            ),
          ),
          const Divider(height: 20, color: Colors.white30),
          Text(
            '⭐ VIP ACCESS UNLOCKED ⭐',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy unlimited access to digital e-books, binaural music tracks, HD video workshops & priority doctor support.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// SHINING SUBSCRIBE BUTTON
class _ShiningSubscribeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;
  final String text;

  const _ShiningSubscribeButton({
    required this.onPressed,
    required this.color,
    required this.text,
  });

  @override
  State<_ShiningSubscribeButton> createState() => _ShiningSubscribeButtonState();
}

class _ShiningSubscribeButtonState extends State<_ShiningSubscribeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
            ),
            child: Center(
              child: Text(
                widget.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Shining Light Sweep Overlay
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              final val = _shimmerController.value;
              if (val > 0.5) return const SizedBox.shrink();

              final progress = val / 0.5;
              final alignX = -2.5 + progress * 5.0;

              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(alignX - 0.5, -1.0),
                        end: Alignment(alignX + 0.5, 1.0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.55),
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
