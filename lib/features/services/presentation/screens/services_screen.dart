import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _selectedCategory = 'All';

  void _bookServiceSession(ServiceItem srv) {
    final currentUser = ref.read(authStateProvider).user;
    final customerName = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'Bee Beeyond Patient';
    final customerPhone = currentUser?.phone.isNotEmpty == true ? currentUser!.phone : 'Self-Service Booking';
    final customerEmail = currentUser?.email.isNotEmpty == true ? currentUser!.email : 'patient@beebeeyond.com';

    final orderId = 'SRV-2025-${(1000 + srv.id.hashCode % 8999).abs()}';
    final receiptId = 'REC-2025-${(5000 + srv.id.hashCode % 4999).abs()}';

    final newReceipt = ReceiptEntity(
      receiptId: receiptId,
      orderId: orderId,
      title: srv.serviceName,
      type: 'SERVICE',
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      deliveryAddress: 'Virtual Consultation Portal (Bee Beeyond Tele-Health)',
      items: [
        ReceiptItem(name: srv.serviceName, quantity: 1, unitPrice: srv.serviceCharge),
      ],
      subtotal: srv.serviceCharge,
      gstRate: 0.18,
      deliveryFee: 0.0,
      discount: 0.0,
      paymentMethod: 'UPI / Online Portal',
      date: DateTime.now(),
    );

    ref.read(receiptsProvider.notifier).addReceipt(newReceipt);

    ref.read(notificationsProvider.notifier).postNotification(
      title: '🩺 Practitioner Session Reserved!',
      message: '1-on-1 slot reserved for "${srv.serviceName}". View tax invoice & appointment details.',
      category: 'services',
    );

    AppAlertManager.showFloatingToast(
      context,
      title: 'Consultation Session Booked!',
      message: 'Reserved 1-on-1 slot for "${srv.serviceName}"',
      icon: Icons.task_alt_rounded,
      backgroundColor: const Color(0xFF0F172A),
      accentColor: const Color(0xFF10B981),
      actionLabel: 'VIEW INVOICE',
      onAction: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReceiptPreviewScreen(receipt: newReceipt),
          ),
        );
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiptPreviewScreen(receipt: newReceipt),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

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
              // Top Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.support_agent_rounded, color: Colors.amberAccent, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Expert Practitioner Consultations',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book 1-on-1 private sessions with certified Ayurvedic doctors, Vastu masters, Bach therapists, and counselors.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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
                            Text(
                              '$_selectedCategory Sessions (${filteredServices.length})',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
    // Beautiful Light-Colored Frame Gradients & Borders
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

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offer Image Banner - FULL IMAGE VISIBLE WITHOUT CUT OFF
          if (srv.offerImageUrl.isNotEmpty)
            Stack(
              children: [
                Container(
                  height: 165,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: srv.offerImageUrl,
                        height: 165,
                        width: double.infinity,
                        fit: BoxFit.contain, // FULL IMAGE VISIBLE WITHOUT CUT OFF
                        placeholder: (context, url) => Container(
                          height: 165,
                          color: const Color(0xFFF1F5F9),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      srv.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(srv.icon, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service Title Row + Small Bee Beeyond Emblem Logo
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  srv.serviceName,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                AssetPaths.beeBeyondEmblem,
                                width: 22,
                                height: 22,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            srv.duration,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  srv.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
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
                        Text(
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
                      text: 'Book Session',
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      onPressed: () => _bookServiceSession(srv),
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
}
