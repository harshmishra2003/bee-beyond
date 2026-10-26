import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/expiry_manager_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../checkout/presentation/providers/payment_provider.dart';
import '../../../../core/services/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/widgets/status_dialog.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../orders/presentation/providers/receipt_provider.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../providers/expiry_provider.dart';
import '../providers/membership_provider.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  RazorpayService? _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _razorpayService?.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _openMembershipCheckoutModal(MembershipPlanEntity plan) {
    String selectedMethod = 'UPI';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final currentUser = ref.read(authStateProvider).user;
          final customerName = currentUser?.name.isNotEmpty == true
              ? currentUser!.name
              : 'Bee Beyonnd VIP Member';
          final customerPhone = currentUser?.phone.isNotEmpty == true
              ? currentUser!.phone
              : 'Self-Service Pass';
          final customerEmail = currentUser?.email.isNotEmpty == true
              ? currentUser!.email
              : 'member@beebeyonnd.com';

          final basePrice = plan.price;
          final gstAmount = basePrice * 0.18;
          final grandTotal = basePrice + gstAmount;

          return Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Plan Banner Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: plan.cardLightBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: plan.cardThemeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: plan.cardThemeColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(plan.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.displayName,
                              style: TextStyle(
                                color: plan.cardThemeColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Validity: ${plan.durationLabel} • VIP Access Pass',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Billing Breakdown Card
                Container(
                  padding: const EdgeInsets.all(16),
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
                          const Text('Pass Base Price',
                              style: TextStyle(
                                  fontSize: 12.5, color: Color(0xFF64748B))),
                          Text(CurrencyUtils.formatINR(basePrice),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GST Tax (18% CGST + SGST)',
                              style: TextStyle(
                                  fontSize: 12.5, color: Color(0xFF64748B))),
                          Text(CurrencyUtils.formatINR(gstAmount),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                        ],
                      ),
                      const Divider(height: 16, color: Color(0xFFE2E8F0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Payable Amount',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          Text(CurrencyUtils.formatINR(grandTotal),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: plan.cardThemeColor)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),

                // Payment Methods Selection List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildPaymentOptionTile(
                        title: 'UPI Express Pay (GPay, PhonePe, Paytm)',
                        subtitle: 'Instant 1-tap payment confirmation',
                        icon: Icons.qr_code_scanner_rounded,
                        isSelected: selectedMethod == 'UPI',
                        onTap: () => setModalState(() => selectedMethod = 'UPI'),
                      ),
                      const SizedBox(height: 8),
                      _buildPaymentOptionTile(
                        title: 'Credit / Debit Card (Visa, MasterCard, RuPay)',
                        subtitle: '100% Encrypted 256-bit SSL Payment',
                        icon: Icons.credit_card_rounded,
                        isSelected: selectedMethod == 'CARD',
                        onTap: () => setModalState(() => selectedMethod = 'CARD'),
                      ),
                      const SizedBox(height: 8),
                      _buildPaymentOptionTile(
                        title: 'Net Banking (SBI, HDFC, ICICI, Axis)',
                        subtitle: 'Direct Secure Bank Authorization',
                        icon: Icons.account_balance_rounded,
                        isSelected: selectedMethod == 'NETBANKING',
                        onTap: () => setModalState(() => selectedMethod = 'NETBANKING'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Pay & Activate Full-Width 3D Button
                ThreeDButton(
                  width: double.infinity,
                  text: 'PAY ${CurrencyUtils.formatINR(grandTotal)} & ACTIVATE PASS ▶',
                  fontSize: 14.5,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  icon: const Icon(Icons.lock_rounded, color: Colors.amberAccent, size: 20),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _executeMembershipPayment(
                      plan: plan,
                      paymentMethod: selectedMethod,
                      grandTotal: grandTotal,
                      customerName: customerName,
                      customerPhone: customerPhone,
                      customerEmail: customerEmail,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _executeMembershipPayment({
    required MembershipPlanEntity plan,
    required String paymentMethod,
    required double grandTotal,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
  }) async {
    final receiptId = 'REC-2025-${(1000 + plan.id.hashCode % 8999).abs()}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
              const SizedBox(height: 20),
              Text(
                'Creating Membership Order...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);

      final serverOrder = await paymentRepo.createServerOrder(
        amount: grandTotal,
        currency: 'INR',
        receiptId: receiptId,
        items: [
          {
            'product_id': int.tryParse('${plan.id}') ?? 1,
            'quantity': 1,
          }
        ],
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
      }

      _razorpayService?.onSuccess = (response) async {
        final paymentId = response.paymentId?.trim();
        final signature = response.signature?.trim();

        if (paymentId == null || paymentId.isEmpty || signature == null || signature.isEmpty) {
          if (mounted) {
            StatusDialog.show(
              context,
              title: 'Payment Incomplete',
              description: 'No valid payment signature returned from payment gateway.',
              isSuccess: false,
              onAction: () {},
              actionText: 'OK',
            );
          }
          return;
        }

        if (!mounted) return;

        StatusDialog.show(
          context,
          title: 'Verifying Membership Payment...',
          description: 'Checking payment signature & database status with server...',
          isLoading: true,
        );

        try {
          final verification = await paymentRepo.verifyPaymentSignature(
            paymentId: paymentId,
            orderId: response.orderId ?? serverOrder.gatewayOrderId,
            signature: signature,
          );

          if (mounted) {
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop(); // Dismiss verification loading
            }

            if (verification.isVerified) {
              final newReceipt = ReceiptEntity(
                receiptId: receiptId,
                orderId: serverOrder.orderId,
                title: plan.displayName,
                type: 'MEMBERSHIP',
                customerName: customerName,
                customerPhone: customerPhone,
                customerEmail: customerEmail,
                deliveryAddress: 'Online VIP Membership Access Pass (Bee Beyonnd Portal)',
                items: [
                  ReceiptItem(name: plan.displayName, quantity: 1, unitPrice: plan.price),
                ],
                subtotal: plan.price,
                gstRate: 0.18,
                deliveryFee: 0.0,
                discount: 0.0,
                paymentMethod: 'Razorpay Gateway',
                date: DateTime.now(),
              );

              ref.read(receiptsProvider.notifier).addReceipt(newReceipt);

              ref.read(activePassProvider.notifier).activatePass(
                    passId: plan.id,
                    passName: plan.displayName,
                    slug: plan.slug,
                    durationYears: plan.accessDuration > 0 ? plan.accessDuration : 1,
                  );

              ref.read(notificationsProvider.notifier).postNotification(
                    title: '⭐ VIP Membership Pass Activated!',
                    message: 'Subscribed to ${plan.displayName}. Official tax invoice $receiptId generated.',
                    category: 'vip_pass',
                  );

              context.push(
                RoutePaths.receiptPreview,
                extra: newReceipt,
              );
            } else {
              StatusDialog.show(
                context,
                title: 'Payment Verification Failed',
                description: verification.message ?? 'Payment status in database is not successful.',
                isSuccess: false,
                onAction: () {},
                actionText: 'CLOSE',
              );
            }
          }
        } catch (e) {
          if (mounted) {
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            StatusDialog.show(
              context,
              title: 'Verification Error',
              description: 'Could not verify payment with server: $e',
              isSuccess: false,
              onAction: () {},
              actionText: 'RETRY',
            );
          }
        }
      };

      _razorpayService?.onError = (response) {
        if (!mounted) return;

        final int? code = response.code;
        final String? msg = response.message;

        final isCancelled = code == Razorpay.PAYMENT_CANCELLED ||
            (msg?.toLowerCase().contains('cancel') ?? false) ||
            (msg?.toLowerCase().contains('dismiss') ?? false) ||
            (msg?.toLowerCase().contains('back') ?? false);

        StatusDialog.show(
          context,
          title: isCancelled ? 'Payment Cancelled' : 'Payment Failed',
          description: isCancelled
              ? 'Payment process was cancelled or dismissed. No amount was debited from your account.'
              : (msg ?? 'Transaction was declined or failed. Please try again.'),
          isSuccess: false,
          onAction: () {},
          actionText: 'OK',
        );
      };

      _razorpayService?.openCheckout(
        keyId: serverOrder.keyId,
        amountPaise: serverOrder.amountPaise,
        gatewayOrderId: serverOrder.gatewayOrderId,
        name: 'Bee Beyonnd',
        description: 'VIP Membership Pass: ${plan.displayName}',
        contact: customerPhone,
        email: customerEmail,
        customerName: customerName,
      );

    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
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

  Widget _buildPaymentOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
                  width: isSelected ? 6.0 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(membershipPlansProvider);
    final activePass = ref.watch(activePassProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FD), // Clean Off-White Light Theme
      appBar: const CustomAppBar(title: 'VIP Membership Cards'),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(membershipPlansProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ACTIVE PASS STATUS CARD
              if (activePass != null) _buildActivePassStatusCard(activePass),

              // ANIMATED HEADER BANNER
              const _AnimatedHeaderBanner(),

              const SizedBox(height: 20),

              // MEMBERSHIP CARDS LIST WITH FULL-SIZE LIGHT THEME ARTWORK BANNERS
              plansAsync.when(
                skipLoadingOnRefresh: true,
                data: (plans) {
                  if (plans.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plans.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return _buildFullSizeLightMembershipCard(plan);
                    },
                  );
                },
                loading: () => _buildLoadingState(),
                error: (error, stackTrace) => _buildErrorState(error.toString()),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivePassStatusCard(UserPassSubscription activePass) {
    Color statusColor = const Color(0xFF10B981);
    if (activePass.status == AccessStatus.expiringSoon) {
      statusColor = const Color(0xFFF59E0B);
    } else if (activePass.isExpired) {
      statusColor = const Color(0xFFEF4444);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activePass.isExpired ? Icons.access_time_filled_rounded : Icons.verified_rounded,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE MEMBER PASS',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        activePass.passName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  activePass.statusLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: activePass.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: 240,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'Fetching VIP Membership Cards...',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          const Text(
            'No Membership Plans Found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please pull down to refresh or check back later.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => ref.invalidate(membershipPlansProvider),
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
            label: const Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          const Text(
            'Could Not Load Membership Plans',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => ref.invalidate(membershipPlansProvider),
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
            label: const Text('Retry Loading', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // FULL-SIZE LIGHT THEME MEMBERSHIP CARD BUILDER
  Widget _buildFullSizeLightMembershipCard(MembershipPlanEntity plan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: plan.cardThemeColor.withValues(alpha: 0.3),
          width: plan.isPopular ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: plan.cardThemeColor.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. FULL SIZE OFFICIAL MEMBERSHIP ARTWORK BANNER
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: AspectRatio(
                  aspectRatio: 1.05,
                  child: Image.asset(
                    plan.bannerAssetPath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: plan.cardLightBg,
                        height: 220,
                        child: Center(
                          child: Icon(plan.icon, size: 80, color: plan.cardThemeColor),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // FLOATING POPULAR BADGE PILL OVERLAY
              if (plan.isPopular || plan.badgeText.isNotEmpty)
                Positioned(
                  top: 14,
                  right: 14,
                  child: _ZoomingWidget(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            plan.cardThemeColor,
                            plan.cardThemeColor.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: plan.cardThemeColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            plan.displayBadgeText,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 2. CARD BODY & DETAILS (LIGHT THEME)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PRICE & DURATION HEADER ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _DigitalClockRollCounter(
                          targetAmount: plan.price,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'INR',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // DURATION PILL BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: plan.cardLightBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: plan.cardThemeColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        plan.durationLabel,
                        style: GoogleFonts.poppins(
                          color: plan.cardThemeColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                const Divider(height: 1, color: AppColors.divider),

                const SizedBox(height: 14),

                // FEATURES LIST
                ...plan.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 9.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: plan.cardThemeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: plan.cardThemeColor,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SHINING PULSING SUBSCRIBE BUTTON
                _ShiningPulsingSubscribeButton(
                  plan: plan,
                  onPressed: () => _openMembershipCheckoutModal(plan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// HEADER BANNER WIDGET IN LIGHT / BRAND GRADIENT
class _AnimatedHeaderBanner extends StatefulWidget {
  const _AnimatedHeaderBanner();

  @override
  State<_AnimatedHeaderBanner> createState() => _AnimatedHeaderBannerState();
}

class _AnimatedHeaderBannerState extends State<_AnimatedHeaderBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animVal = _controller.value;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(AppColors.primaryDark, AppColors.primary, animVal)!,
                Color.lerp(AppColors.primary, AppColors.secondary, animVal)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(
                AssetPaths.beeBeyondEmblem,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'BEE BEYONND VIP MEMBERSHIP',
                          style: GoogleFonts.poppins(
                            color: Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 12),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Choose Your Healing Pass',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Unlock discounts, live webinars & 1-on-1 doctor guidance.',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// SHINING PULSING SUBSCRIBE BUTTON WITH PERIODIC LIGHT BEAM
class _ShiningPulsingSubscribeButton extends StatefulWidget {
  final MembershipPlanEntity plan;
  final VoidCallback onPressed;

  const _ShiningPulsingSubscribeButton({
    required this.plan,
    required this.onPressed,
  });

  @override
  State<_ShiningPulsingSubscribeButton> createState() => _ShiningPulsingSubscribeButtonState();
}

class _ShiningPulsingSubscribeButtonState extends State<_ShiningPulsingSubscribeButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shineAnimation = Tween<double>(begin: -1.2, end: 2.2).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOutCubic),
    );

    _startShineLoop();
  }

  void _startShineLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (mounted) {
        await _shineController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseScale = 1.0 + (_pulseController.value * 0.02);

        return Transform.scale(
          scale: pulseScale,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.plan.cardThemeColor,
                            widget.plan.cardThemeColor.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: widget.plan.cardThemeColor.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: widget.onPressed,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CLAIM ${widget.plan.name.toUpperCase()} PASS',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Periodic Shining Glint Light Beam
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shineAnimation,
                        builder: (context, child) {
                          return FractionalTranslation(
                            translation: Offset(_shineAnimation.value, 0),
                            child: Transform.rotate(
                              angle: 0.35,
                              child: Container(
                                width: 32,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.7),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// DIGITAL CLOCK ROLL-DOWN ANIMATED COUNTER
class _DigitalClockRollCounter extends StatelessWidget {
  final double targetAmount;
  final TextStyle style;

  const _DigitalClockRollCounter({
    required this.targetAmount,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetAmount),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutBack,
      builder: (context, val, child) {
        return Text(
          CurrencyUtils.formatINR(val),
          style: style,
        );
      },
    );
  }
}

// ZOOMING WIDGET
class _ZoomingWidget extends StatefulWidget {
  final Widget child;

  const _ZoomingWidget({required this.child});

  @override
  State<_ZoomingWidget> createState() => _ZoomingWidgetState();
}

class _ZoomingWidgetState extends State<_ZoomingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.08);
        return Transform.scale(scale: scale, child: widget.child);
      },
    );
  }
}
