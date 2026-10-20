import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/asset_paths.dart';
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
  final List<Color> shineColors;
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
    required this.shineColors,
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
      gradientColors: [Color(0xFFCBD5E1), Color(0xFF94A3B8), Color(0xFF475569)],
      shineColors: [
        Colors.transparent,
        Color(0x30FFFFFF),
        Color(0xFFFFFFFF),
        Color(0x30FFFFFF),
        Colors.transparent,
      ],
      accentColor: Color(0xFF334155),
      textColor: Color(0xFF0F172A),
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
      shineColors: [
        Colors.transparent,
        Color(0x50FCD34D),
        Color(0xFFFFFBEB),
        Color(0x50FCD34D),
        Colors.transparent,
      ],
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
      shineColors: [
        Colors.transparent,
        Color(0x50A5B4FC),
        Color(0xFFEEF2FF),
        Color(0x50A5B4FC),
        Colors.transparent,
      ],
      accentColor: Color(0xFF818CF8),
      textColor: Colors.white,
      icon: Icons.military_tech_rounded,
      benefits: [
        '40% FLAT OFF ON EVERYTHING Across Bee Beeyond Portal',
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
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _subscribePlan(MembershipPlan plan) {
    final receiptId = 'REC-2025-${(1000 + plan.id.hashCode % 8999).abs()}';
    final orderId = 'MBR-2025-${(5000 + plan.id.hashCode % 4999).abs()}';

    final newReceipt = ReceiptEntity(
      receiptId: receiptId,
      orderId: orderId,
      title: plan.name,
      type: 'SERVICE',
      customerName: 'Aarav Sharma',
      customerPhone: '+91 9876543210',
      customerEmail: 'aarav@example.com',
      deliveryAddress: 'Online VIP Membership Access Pass (Bee Beeyond Portal)',
      items: [
        ReceiptItem(name: plan.name, quantity: 1, unitPrice: plan.price),
      ],
      subtotal: plan.price,
      gstRate: 0.18,
      deliveryFee: 0.0,
      discount: 0.0,
      paymentMethod: 'UPI / Card (Online)',
      date: DateTime.now(),
    );

    ref.read(receiptsProvider.notifier).addReceipt(newReceipt);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscribed to ${plan.name} successfully!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiptPreviewScreen(receipt: newReceipt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'VIP Membership Cards'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ANIMATED HEADER BANNER
            const _AnimatedHeaderBanner(),

            const SizedBox(height: 20),

            // MEMBERSHIP CARDS LIST
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _plans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return _buildShimmeringMembershipCard(plan);
              },
            ),

            const SizedBox(height: 32),
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
        final shimmerPos = _shimmerController.value * 2.8 - 0.9;

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
                          Icon(plan.icon, color: plan.isPopular ? Colors.amberAccent : Colors.white, size: 26),
                          const SizedBox(width: 8),
                          Text(
                            plan.tag,
                            style: TextStyle(
                              color: plan.isPopular ? Colors.amberAccent : Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (plan.isPopular) ...[
                            const SizedBox(width: 8),
                            _ZoomingWidget(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Text(
                                  'BEST VALUE',
                                  style: TextStyle(color: Color(0xFF78350F), fontSize: 9, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Reserved Space for Top Right Brand Emblem
                      const SizedBox(width: 36),
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

                  // DIGITAL CLOCK ROLL-DOWN ANIMATED PRICE COUNTER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      _DigitalClockRollCounter(
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

                  const SizedBox(height: 20),

                  // Shiny Glossy Pulsing Subscribe Button
                  _ShiningPulsingSubscribeButton(
                    plan: plan,
                    onPressed: () => _subscribePlan(plan),
                  ),
                ],
              ),
            ),

            // BACKGROUND TRANSPARENT COLOR-ADAPTIVE EMBLEM WATERMARK
            Positioned(
              right: -15,
              bottom: -15,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.22,
                  child: Image.asset(
                    AssetPaths.beeBeyondEmblem,
                    width: 165,
                    height: 165,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // TOP RIGHT CORNER TRANSPARENT EMBLEM LOGO (NO WHITE BG)
            Positioned(
              top: 14,
              right: 14,
              child: Image.asset(
                AssetPaths.beeBeyondEmblem,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),

            // COLOR-SPECIFIC METALLIC SHIMMER LIGHT STREAK OVERLAY
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: plan.shineColors,
                        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
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

// ANIMATED & CRISP HEADER ANNOUNCEMENT BANNER WIDGET
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

        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(const Color(0xFF312E81), const Color(0xFF4338CA), animVal)!,
                    Color.lerp(const Color(0xFF4F46E5), const Color(0xFF1E1B4B), animVal)!,
                    Color.lerp(const Color(0xFF6366F1), const Color(0xFF3730A3), animVal)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amberAccent.withAlpha(100), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x334B489B),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Fully Transparent Bee Beeyond Emblem Logo
                  Image.asset(
                    AssetPaths.beeBeyondEmblem,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 14),

                  // Header Texts
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'BEE BEEYOND HEALING PASSES',
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 12),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Select Your Preferred Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Unlock discounts, live webinars & 1-on-1 doctor guidance.',
                          style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// SHINING PULSING SUBSCRIBE BUTTON
class _ShiningPulsingSubscribeButton extends StatefulWidget {
  final MembershipPlan plan;
  final VoidCallback onPressed;

  const _ShiningPulsingSubscribeButton({
    required this.plan,
    required this.onPressed,
  });

  @override
  State<_ShiningPulsingSubscribeButton> createState() => _ShiningPulsingSubscribeButtonState();
}

class _ShiningPulsingSubscribeButtonState extends State<_ShiningPulsingSubscribeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
        final pulseScale = 1.0 + (_controller.value * 0.03);

        return Transform.scale(
          scale: pulseScale,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.plan.isPopular ? Colors.amberAccent : Colors.white,
                foregroundColor: widget.plan.isPopular ? const Color(0xFF78350F) : widget.plan.accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: widget.plan.isPopular ? 4 : 0,
              ),
              onPressed: widget.onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CLAIM ${widget.plan.tag}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
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
