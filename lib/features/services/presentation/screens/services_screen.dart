import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/membership_access_guard.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../orders/presentation/providers/receipt_provider.dart';
import '../../../orders/presentation/screens/receipt_preview_screen.dart';
import '../../domain/entities/service_item.dart';
import '../providers/services_provider.dart';
import '../../../../core/services/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/widgets/status_dialog.dart';
import '../../../checkout/presentation/providers/payment_provider.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _selectedCategory = 'All';
  RazorpayService? _razorpayService;

  bool _isLottieActive = true;
  DateTime? _dataResponseTime;
  Timer? _postResponseTimer;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
  }

  @override
  void dispose() {
    _postResponseTimer?.cancel();
    _razorpayService?.dispose();
    super.dispose();
  }

  void _bookServiceSession(ServiceItem srv, String slotId) async {
    final currentUser = ref.read(authStateProvider).user;
    final customerName = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'Bee Beyonnd Patient';
    final customerPhone = currentUser?.phone.isNotEmpty == true ? currentUser!.phone : '9876543210';
    final customerEmail = currentUser?.email.isNotEmpty == true ? currentUser!.email : 'patient@beebeyonnd.com';

    final receiptId = 'REC-2025-${(5000 + srv.id.hashCode % 4999).abs()}';

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
                'Securing Selected Slot...',
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
        amount: srv.serviceCharge,
        currency: 'INR',
        receiptId: receiptId,
        items: [
          {
            'product_id': srv.id,
            'slot_id': slotId, // Pass the selected slot ID to backend
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
          title: 'Confirming Slot Booking...',
          description: 'Locking slot and verifying payment with server...',
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
                title: srv.serviceName,
                type: 'SERVICE_APPOINTMENT',
                customerName: customerName,
                customerPhone: customerPhone,
                customerEmail: customerEmail,
                deliveryAddress: 'Virtual Consultation / Selected Slot: $slotId',
                items: [
                  ReceiptItem(name: srv.serviceName, quantity: 1, unitPrice: srv.serviceCharge),
                ],
                subtotal: srv.serviceCharge,
                gstRate: 0.18,
                deliveryFee: 0.0,
                discount: 0.0,
                paymentMethod: 'Razorpay Gateway',
                date: DateTime.now(),
              );

              ref.read(receiptsProvider.notifier).addReceipt(newReceipt);

              ref.read(notificationsProvider.notifier).postNotification(
                title: '🩺 Appointment Confirmed!',
                message: 'Your slot for "${srv.serviceName}" has been successfully booked.',
                category: 'services',
              );

              // 💥 Refresh the services data so the UI reflects the newly booked slot (Greys it out)
              ref.invalidate(servicesProvider);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReceiptPreviewScreen(receipt: newReceipt),
                ),
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

        final failureResp = response is PaymentFailureResponse ? response : null;
        final int? code = failureResp?.code;
        final String? msg = failureResp?.message;

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
        description: 'Consultation: ${srv.serviceName}',
        contact: customerPhone,
        email: customerEmail,
        customerName: customerName,
      );

    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
        StatusDialog.show(
          context,
          title: 'Order Creation Error',
          description: '$e',
          isSuccess: false,
          onAction: () {},
          actionText: 'OK',
        );
      }
    }
  }

  void _showDescriptionImageModal(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(
                    height: 150,
                    child: Center(
                      child: Text('Description Infographic Image', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _extractCategories(List<ServiceItem> services) {
    final Set<String> cats = {'All'};
    for (var s in services) {
      if (s.category.isNotEmpty) cats.add(s.category);
    }
    return cats.toList();
  }

  Widget _buildServicesLottieLoadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFAF9FE),
            Color(0xFFFFFFFF),
            Color(0xFFF2F0FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Lottie.asset(
          AssetPaths.lottieLoading,
          width: 260,
          height: 260,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.medical_services_rounded,
            size: 80,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

    if (servicesAsync.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9FE),
        body: _buildServicesLottieLoadingOverlay(),
      );
    }

    return MembershipAccessGuard(
      featureName: 'Doctor Consultations & Services',
      featureDescription: '1-on-1 practitioner bookings, Prakriti analysis & Vastu consultations',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Wellness & Consultation Services'),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(servicesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              // Top Hero Banner with Radiant Wellness Gradients
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4A154B),
                      Color(0xFF7E22CE),
                      Color(0xFF4338CA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x307E22CE),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.spa_rounded,
                        size: 110,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.support_agent_rounded, color: Colors.amberAccent, size: 24),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Expert Practitioner Sessions',
                              style: GoogleFonts.poppins(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Book 1-on-1 private consultations with certified Ayurvedic doctors, Vastu masters, Bach therapists, and mind-body experts.',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Services List & Category Filter
              servicesAsync.when(
                skipLoadingOnRefresh: true,
                data: (servicesList) {
                  if (servicesList.isEmpty) {
                    return _buildEmptyState();
                  }

                  final categories = _extractCategories(servicesList);
                  final filteredServices = servicesList.where((s) {
                    if (_selectedCategory == 'All') return true;
                    return s.category.toLowerCase() == _selectedCategory.toLowerCase();
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Filter Chips Bar
                      if (categories.length > 1)
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isSelected = _selectedCategory == cat;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Services List Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$_selectedCategory Sessions (${filteredServices.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 22),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Services Cards
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredServices.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final srv = filteredServices[index];
                          return _buildServiceCard(context, srv, index);
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error loading services: $err', style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Wellness Services Available Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our team of certified practitioners and doctors will publish consultation schedules shortly. Pull down to refresh!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem srv, int index) {
    final frameGradients = [
      const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF0FDF4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFFFBEB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFAF5FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    final frameBorders = [
      const Color(0xFFC7D2FE), // Indigo light border
      const Color(0xFFA7F3D0), // Mint green light border
      const Color(0xFFFDE68A), // Amber gold light border
      const Color(0xFFE9D5FF), // Purple light border
    ];

    final gradient = frameGradients[index % frameGradients.length];
    final borderColor = frameBorders[index % frameBorders.length];

    final totalSlots = srv.totalSlotsToday;
    final bookedSlots = srv.bookedSlotsCount;
    final remainingSlots = srv.remainingSlotsCount;
    final hasSlotsData = totalSlots > 0;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real-time Availability Counter Dashboard
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             decoration: const BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
               border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: hasSlotsData && remainingSlots > 0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Today\'s Slot Availability',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasSlotsData
                            ? '$remainingSlots Available | $totalSlots Total'
                            : 'Open for Booking Today',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasSlotsData && remainingSlots > 0
                              ? const Color(0xFF059669)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Dynamic Segmented Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: hasSlotsData
                        ? Row(
                            children: [
                               Expanded(
                                 flex: bookedSlots > 0 ? bookedSlots : 0,
                                 child: Container(height: 6, color: const Color(0xFF94A3B8)), // Booked: Grey
                               ),
                               Expanded(
                                 flex: remainingSlots > 0 ? remainingSlots : 1,
                                 child: Container(height: 6, color: const Color(0xFF10B981)), // Remaining: Emerald
                               ),
                            ],
                          )
                        : Container(
                            height: 6,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                              ),
                            ),
                          ),
                  ),
               ],
             ),
          ),

          // Offer Image Banner - CLEAN WITHOUT ANY OVERLAY TEXT (Compact height)
          if (srv.offerImageUrl.isNotEmpty)
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
              ),
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: srv.offerImageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: const Color(0xFFF8FAFC),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.primary.withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(srv.icon, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service Title Row + Category Tag & Small Emblem Logo
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  srv.serviceName,
                                  style: GoogleFonts.epilogue(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                AssetPaths.beeBeyondEmblem,
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  srv.category.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF64748B),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 10, color: AppColors.primary),
                                    const SizedBox(width: 3),
                                    Text(
                                      srv.duration,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primary,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  srv.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF475569),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),

                // Description Image Infographic Button (if available)
                if (srv.descriptionImageUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showDescriptionImageModal(srv.descriptionImageUrl, srv.serviceName),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        const Text(
                          'View Session Details & Infographic →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Post-Booking Media Access
                if (srv.slots.any((s) => s.isBookedByMe)) ...[
                   const SizedBox(height: 16),
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: const Color(0xFFF0FDF4), // Light Green bg
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: const Color(0xFF86EFAC)),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'You have a booked appointment',
                                style: TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                          if (srv.meetingLink.isNotEmpty) ...[
                             const SizedBox(height: 10),
                             SizedBox(
                               width: double.infinity,
                               child: ElevatedButton.icon(
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: const Color(0xFF10B981),
                                   foregroundColor: Colors.white,
                                   elevation: 0,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                 ),
                                 icon: const Icon(Icons.video_call_rounded, size: 20),
                                 label: const Text('JOIN MEETING NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                 onPressed: () {
                                    // Normally you would launch the URL here
                                    AppAlertManager.showFloatingToast(context, title: 'Opening Meeting...', message: 'Connecting to virtual room', icon: Icons.videocam);
                                 },
                               ),
                             ),
                          ],
                          if (srv.mediaPdfs.isNotEmpty || srv.mediaVideos.isNotEmpty) ...[
                             const SizedBox(height: 10),
                             const Text('Provided Materials:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                             const SizedBox(height: 4),
                             ...srv.mediaPdfs.map((pdf) => Padding(
                               padding: const EdgeInsets.only(bottom: 4.0),
                               child: Row(
                                 children: [
                                   const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 14),
                                   const SizedBox(width: 4),
                                   Expanded(child: Text(pdf.title, style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A), decoration: TextDecoration.underline))),
                                 ],
                               ),
                             )),
                             ...srv.mediaVideos.map((vid) => Padding(
                               padding: const EdgeInsets.only(bottom: 4.0),
                               child: Row(
                                 children: [
                                   const Icon(Icons.play_circle_rounded, color: AppColors.primary, size: 14),
                                   const SizedBox(width: 4),
                                   Expanded(child: Text(vid.title, style: const TextStyle(fontSize: 11, color: AppColors.primary, decoration: TextDecoration.underline))),
                                 ],
                               ),
                             )),
                          ],
                       ],
                     ),
                   ),
                ],

                const SizedBox(height: 16),

                // Price & Booking Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyUtils.formatINR(srv.serviceCharge),
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        if (srv.offerPrice > srv.serviceCharge)
                          Text(
                            CurrencyUtils.formatINR(srv.offerPrice),
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    ThreeDButton(
                      text: 'Book Appointment',
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      onPressed: () => _showServiceBookingSheet(context, srv),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Beautiful Bottom Sheet for booking slots
  void _showServiceBookingSheet(BuildContext context, ServiceItem srv) {
    ServiceSlot? selectedSlot;
    DateTime selectedDate = DateTime.now();
    int weekOffset = 0; // 0 = current week, 1 = next week, etc.

    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    // Helper to calculate start of the week (Monday)
    DateTime getStartOfWeek(DateTime now, int offset) {
      final target = now.add(Duration(days: offset * 7));
      return target.subtract(Duration(days: target.weekday - 1));
    }

    // Helper to generate slots for selected date
    List<ServiceSlot> getSlotsForDate(DateTime date) {
      if (isSameDay(date, DateTime.now()) && srv.slots.isNotEmpty) {
        return srv.slots;
      }
      final dateTag = DateFormat('yyyyMMdd').format(date);
      return [
        ServiceSlot(slotId: 'slot_${dateTag}_0900', timeLabel: '09:00 AM - 09:45 AM', isBooked: false),
        ServiceSlot(slotId: 'slot_${dateTag}_1030', timeLabel: '10:30 AM - 11:15 AM', isBooked: false),
        ServiceSlot(slotId: 'slot_${dateTag}_1200', timeLabel: '12:00 PM - 12:45 PM', isBooked: true),
        ServiceSlot(slotId: 'slot_${dateTag}_1430', timeLabel: '02:30 PM - 03:15 PM', isBooked: false),
        ServiceSlot(slotId: 'slot_${dateTag}_1600', timeLabel: '04:00 PM - 04:45 PM', isBooked: false),
        ServiceSlot(slotId: 'slot_${dateTag}_1730', timeLabel: '05:30 PM - 06:15 PM', isBooked: true),
        ServiceSlot(slotId: 'slot_${dateTag}_1900', timeLabel: '07:00 PM - 07:45 PM', isBooked: false),
      ];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (sheetContext, scrollController) => StatefulBuilder(
          builder: (ctx, setSheetState) {
            final mediaQuery = MediaQuery.maybeOf(ctx);

            final startOfWeek = getStartOfWeek(DateTime.now(), weekOffset);
            final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
            final activeSlots = getSlotsForDate(selectedDate);
            final availableSlots = activeSlots.where((s) => !s.isBooked).toList();
            final bookedSlots = activeSlots.where((s) => s.isBooked && !s.isBookedByMe).toList();

            final weekRangeStr = "${DateFormat('dd MMM').format(startOfWeek)} - ${DateFormat('dd MMM yyyy').format(startOfWeek.add(const Duration(days: 6)))}";

            return Padding(
              padding: EdgeInsets.only(bottom: mediaQuery?.viewInsets.bottom ?? 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
                  ],
                ),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Handle Bar
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // SERVICE HEADER CARD WITH GRADIENT BORDER & ACCENT
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F0C20), Color(0xFF1E1B4B), Color(0xFF312E81)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x251E1B4B), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 1.5),
                        ),
                        child: Icon(srv.icon, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    srv.category.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 10, color: Colors.white),
                                      const SizedBox(width: 3),
                                      Text(
                                        srv.duration,
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              srv.serviceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // WEEK TO WEEK & DATE FILTER SECTION WITH FEATURED CALENDAR ICON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Day & Date',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          weekOffset == 0 ? 'This Week • $weekRangeStr' : 'Week Range • $weekRangeStr',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // FEATURED CALENDAR FILTER BUTTON ICON
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setSheetState(() {
                            selectedDate = picked;
                            selectedSlot = null; // reset slot selection on date change
                            // Calculate week offset relative to today
                            final now = DateTime.now();
                            final diffDays = picked.difference(now).inDays;
                            weekOffset = (diffDays / 7).floor();
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              'Pick Date',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
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

                const SizedBox(height: 10),

                // WEEK TO WEEK NAVIGATION CONTROL (< THIS WEEK >)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: weekOffset > 0
                          ? () {
                              setSheetState(() {
                                weekOffset--;
                                selectedDate = getStartOfWeek(DateTime.now(), weekOffset);
                                selectedSlot = null;
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chevron_left_rounded,
                              size: 18,
                              color: weekOffset > 0 ? AppColors.primary : Colors.grey.shade400,
                            ),
                            Text(
                              'Prev Week',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: weekOffset > 0 ? AppColors.primary : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Text(
                      weekOffset == 0 ? 'CURRENT WEEK' : 'WEEK +$weekOffset',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: AppColors.primary,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        setSheetState(() {
                          weekOffset++;
                          selectedDate = getStartOfWeek(DateTime.now(), weekOffset);
                          selectedSlot = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              'Next Week',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // DAY & DATE PILLS CAROUSEL (7 DAYS OF SELECTED WEEK)
                SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: weekDays.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final dayDate = weekDays[index];
                      final isSelected = isSameDay(dayDate, selectedDate);
                      final isToday = isSameDay(dayDate, DateTime.now());
                      final isPast = dayDate.isBefore(DateTime.now().subtract(const Duration(days: 1))) && !isToday;

                      return GestureDetector(
                        onTap: isPast
                            ? null
                            : () {
                                setSheetState(() {
                                  selectedDate = dayDate;
                                  selectedSlot = null;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isPast ? Colors.grey.shade100 : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isToday ? AppColors.primary.withValues(alpha: 0.6) : const Color(0xFFE2E8F0)),
                              width: isSelected || isToday ? 1.6 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF312E81).withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isToday ? 'TODAY' : DateFormat('EEE').format(dayDate).toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.amberAccent
                                      : (isPast ? Colors.grey.shade400 : AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('d').format(dayDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? Colors.white
                                      : (isPast ? Colors.grey.shade400 : AppColors.textPrimary),
                                ),
                              ),
                              Text(
                                DateFormat('MMM').format(dayDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: isSelected
                                      ? Colors.white70
                                      : (isPast ? Colors.grey.shade400 : AppColors.textHint),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 16),

                // SCROLLABLE SLOTS CONTENT AREA
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AVAILABLE SLOTS SECTION (GREEN)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Available Time Slots',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${availableSlots.length} Available',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (availableSlots.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: availableSlots.map((slot) {
                              final isSelected = selectedSlot?.slotId == slot.slotId;
                              return GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    selectedSlot = slot;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF059669) : const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF047857) : const Color(0xFFA7F3D0),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF059669).withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected ? Icons.check_circle_rounded : Icons.access_time_rounded,
                                        size: 14,
                                        color: isSelected ? Colors.white : const Color(0xFF059669),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        slot.timeLabel,
                                        style: GoogleFonts.poppins(
                                          color: isSelected ? Colors.white : const Color(0xFF065F46),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "No available slots for this selected date.",
                              style: GoogleFonts.poppins(
                                color: Colors.red.shade400,
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // BOOKED SLOTS SECTION (GREY)
                        if (bookedSlots.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Text(
                                'Booked Time Slots',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: bookedSlots.map((slot) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_clock, size: 12, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 5),
                                    Text(
                                      slot.timeLabel,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11.5,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // SELECTED SLOT SUMMARY BANNER (IF SLOT SELECTED)
                if (selectedSlot != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: ${DateFormat('EEE, dd MMM').format(selectedDate)} • ${selectedSlot!.timeLabel}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // PRICING SUMMARY & BUY NOW BUTTON
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Consultation Fee',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                CurrencyUtils.formatINR(srv.serviceCharge),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (srv.offerPrice > srv.serviceCharge) ...[
                                const SizedBox(width: 6),
                                Text(
                                  CurrencyUtils.formatINR(srv.offerPrice),
                                  style: GoogleFonts.poppins(
                                    decoration: TextDecoration.lineThrough,
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedSlot != null ? AppColors.primary : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          elevation: selectedSlot != null ? 3 : 0,
                        ),
                        onPressed: selectedSlot != null
                            ? () {
                                Navigator.pop(ctx);
                                _bookServiceSession(srv, selectedSlot!.slotId);
                              }
                            : null,
                        icon: const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 18),
                        label: Text(
                          selectedSlot != null ? 'PAY & CONFIRM' : 'SELECT A SLOT',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}
