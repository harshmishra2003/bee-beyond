import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../orders/presentation/providers/receipt_provider.dart';
import '../../../orders/presentation/screens/receipt_preview_screen.dart';

class MembershipPlan {
  final String id;
  final String name;
  final String tag;
  final double price;
  final String duration;
  final List<Color> gradientColors;
  final Color accentColor;
  final Color textColor;
  final IconData icon;
  final List<String> benefits;
  final bool isPopular;

  const MembershipPlan({
    required this.id,
    required this.name,
    required this.tag,
    required this.price,
    required this.duration,
    required this.gradientColors,
    required this.accentColor,
    required this.textColor,
    required this.icon,
    required this.benefits,
    this.isPopular = false,
  });
}

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  final List<MembershipPlan> _plans = const [
    MembershipPlan(
      id: 'plan_silver',
      name: 'Silver Membership Card',
      tag: 'SILVER SHINE PASS',
      price: 1200.0,
      duration: '1 YEAR ACCESS',
      gradientColors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF64748B)],
      accentColor: Color(0xFF475569),
      textColor: Color(0xFF1E293B),
      icon: Icons.workspace_premium_rounded,
      benefits: [
        '10% Flat Discount on All Bach & Ayurvedic Remedies',
        'Unlimited Access to Healing Music & Audio Library',
        'Free Digital E-Books & Chart PDFs',
        'Standard Customer Support',
      ],
    ),
    MembershipPlan(
      id: 'plan_gold',
      name: 'Gold Membership Card',
      tag: 'MOST POPULAR PASS',
      price: 1000.0,
      duration: '1 YEAR ACCESS',
      isPopular: true,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
      accentColor: Color(0xFF78350F),
      textColor: Colors.white,
      icon: Icons.stars_rounded,
      benefits: [
        '15% Flat Discount on Courses, Remedies & Vastu Services',
        'Free Monthly Live Breathwork & Meditation Webinars',
        'Priority Q&A Access in Student Forums',
        'Unlimited Audio & PDF Material Downloads',
      ],
    ),
    MembershipPlan(
      id: 'plan_platinum',
      name: 'Platinum Membership Card',
      tag: 'ROYAL PLATINUM PASS',
      price: 1100.0,
      duration: '1 YEAR ACCESS',
      gradientColors: [Color(0xFF6366F1), Color(0xFF4338CA), Color(0xFF312E81)],
      accentColor: Color(0xFF818CF8),
      textColor: Colors.white,
      icon: Icons.military_tech_rounded,
      benefits: [
        '25% Flat Discount on All Certified Masterclasses & Products',
        'Free VIP Vastu Assessment Report (Worth ₹1,500)',
        'Dedicated Personal Wellness Coach on WhatsApp',
        'Exclusive Early Access to New Course Modules',
      ],
    ),
    MembershipPlan(
      id: 'plan_diamond',
      name: 'Diamond VIP Membership Card',
      tag: 'ULTIMATE DIAMOND CUT PASS',
      price: 2000.0,
      duration: '1 YEAR VIP ACCESS',
      gradientColors: [Color(0xFF0288D1), Color(0xFF00695C), Color(0xFF00ACC1), Color(0xFF80DEEA)],
      accentColor: Color(0xFF00838F),
      textColor: Colors.white,
      icon: Icons.diamond_rounded,
      benefits: [
        '40% FLAT OFF ON EVERYTHING Across Bee Beyond Portal',
        '1-on-1 Personal Video Consultation with Doctor (1 Hour)',
        'Unlimited Lifetime Video Workshop Recordings Access',
        'Free Express Pan-India Delivery & Priority Tax Invoices',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _subscribePlan(MembershipPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => _MembershipPurchaseDialog(
        plan: plan,
        onConfirm: () {
          Navigator.pop(ctx);
          _completeMembershipPurchase(plan);
        },
      ),
    );
  }

  void _completeMembershipPurchase(MembershipPlan plan) {
    final randomId = (1000 + math.Random().nextInt(8999)).toString();
    final receiptId = 'REC-2025-VIP-$randomId';
    final orderId = 'MEM-2025-$randomId';

    final receipt = ReceiptEntity(
      receiptId: receiptId,
      orderId: orderId,
      title: '${plan.name} (${plan.duration})',
      type: 'SERVICE',
      customerName: 'Aarav Sharma',
      customerPhone: '+91 9876543210',
      customerEmail: 'aarav@example.com',
      deliveryAddress: 'Online VIP Membership Access Pass (Bee Beyond Portal)',
      items: [
        ReceiptItem(name: plan.name, quantity: 1, unitPrice: plan.price),
      ],
      subtotal: plan.price,
      gstRate: 0.18,
      deliveryFee: 0.0,
      discount: 0.0,
      paymentMethod: 'UPI / VIP Gateway',
      date: DateTime.now(),
    );

    // Add receipt to provider
    ref.read(receiptsProvider.notifier).addReceipt(receipt);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Congratulations! You are now subscribed to ${plan.name}!'),
        backgroundColor: AppColors.success,
      ),
    );

    // Open Tax Invoice
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiptPreviewScreen(receipt: receipt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: const CustomAppBar(title: 'VIP Membership & Healing Passes'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // HEADER ANNOUNCEMENT BANNER
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x284B489B), blurRadius: 12, offset: Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    AssetPaths.beeBeyondImage1,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 40),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BEE BEYOND HEALING PASSES',
                          style: TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select Your Preferred Plan',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Unlock discounts, live webinars & 1-on-1 doctor guidance.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MEMBERSHIP CARDS LIST WITH METALLIC SHIMMER
            ..._plans.map((plan) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _buildShimmeringMembershipCard(plan),
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // SHIMMERING METALLIC CARD BUILDER
  Widget _buildShimmeringMembershipCard(MembershipPlan plan) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerPos = _shimmerController.value * 2.5 - 0.75;

        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: plan.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: plan.isPopular ? Colors.amberAccent : Colors.white.withAlpha(120),
                  width: plan.isPopular ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: plan.gradientColors.first.withAlpha(90),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(plan.icon, color: plan.isPopular ? Colors.amberAccent : Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            plan.tag,
                            style: TextStyle(
                              color: plan.isPopular ? Colors.amberAccent : Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      if (plan.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amberAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(color: Color(0xFF78350F), fontSize: 9.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    plan.name,
                    style: TextStyle(
                      color: plan.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Slowly Interpolating Price Counter
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      _AnimatedPriceCounter(
                        targetAmount: plan.price,
                        style: TextStyle(
                          color: plan.textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '/ ${plan.duration}',
                        style: TextStyle(color: plan.textColor.withAlpha(200), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: Colors.white30, height: 1),
                  ),

                  // Benefits Checklist
                  ...plan.benefits.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                b,
                                style: TextStyle(
                                  color: plan.textColor.withAlpha(230),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 18),

                  // Shiny Glossy Subscribe Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: plan.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: () => _subscribePlan(plan),
                      icon: Icon(Icons.bolt_rounded, color: plan.accentColor, size: 20),
                      label: Text(
                        'SUBSCRIBE NOW →',
                        style: TextStyle(
                          color: plan.accentColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // METALLIC SHIMMER LIGHT STREAK OVERLAY
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: const [
                          Colors.transparent,
                          Colors.white24,
                          Colors.white60,
                          Colors.white24,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                        begin: Alignment(shimmerPos - 1.0, -0.5),
                        end: Alignment(shimmerPos, 0.5),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(color: Colors.white.withAlpha(1)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// SLOWLY INTERPOLATING ANIMATED PRICE COUNTER
class _AnimatedPriceCounter extends StatelessWidget {
  final double targetAmount;
  final TextStyle style;

  const _AnimatedPriceCounter({
    required this.targetAmount,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetAmount),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          CurrencyUtils.formatINR(value),
          style: style,
        );
      },
    );
  }
}

// PURCHASE CONFIRMATION DIALOG
class _MembershipPurchaseDialog extends StatelessWidget {
  final MembershipPlan plan;
  final VoidCallback onConfirm;

  const _MembershipPurchaseDialog({
    required this.plan,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final gst = plan.price * 0.18;
    final grandTotal = plan.price + gst;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: plan.gradientColors.first.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(plan.icon, color: plan.gradientColors.first, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(plan.duration, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Financial Summary (Incl. 18% GST):', style: TextStyle(fontSize: 11.5, color: AppColors.textHint, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildRow('Base Pass Fee', CurrencyUtils.formatINR(plan.price)),
                  const SizedBox(height: 4),
                  _buildRow('CGST (9%)', CurrencyUtils.formatINR(gst / 2)),
                  const SizedBox(height: 4),
                  _buildRow('SGST (9%)', CurrencyUtils.formatINR(gst / 2)),
                  const Divider(height: 16, color: AppColors.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PAYABLE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      Text(CurrencyUtils.formatINR(grandTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onConfirm,
                    child: const Text('PAY & SUBSCRIBE →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
