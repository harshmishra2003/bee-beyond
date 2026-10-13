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
      shineColors: [
        Colors.transparent,
        Color(0x5080DEEA),
        Color(0xFFE0F7FA),
        Color(0x5080DEEA),
        Colors.transparent,
      ],
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
      duration: const Duration(milliseconds: 2600),
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

    ref.read(receiptsProvider.notifier).addReceipt(receipt);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Congratulations! You are now subscribed to ${plan.name}!'),
        backgroundColor: AppColors.success,
      ),
    );

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
            // ANIMATED & CRISP HEADER ANNOUNCEMENT BANNER
            const _AnimatedHeaderBanner(),

            const SizedBox(height: 20),

            // MEMBERSHIP CARDS LIST WITH METALLIC SHIMMER & BRAND EMBLEM
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
                  // Card Header Row (No Overlap with Top-Right Emblem)
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
                      const SizedBox(width: 32),
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

            // TOP RIGHT CORNER BRAND LOGO EMBLEM (CLEANLY POSITIONED WITH ZERO OVERLAP)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    AssetPaths.beeBeyondImage2,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
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
                  // Crisp & Sharp White Avatar Badge for Bee Beyond Emblem Logo
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AssetPaths.beeBeyondImage2,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                              'BEE BEYOND HEALING PASSES',
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

            // Animated Light Streak Shine Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      final pos = animVal * 2.8 - 0.9;
                      return LinearGradient(
                        colors: const [
                          Colors.transparent,
                          Colors.white10,
                          Colors.white38,
                          Colors.white10,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                        begin: Alignment(pos - 1.0, -0.5),
                        end: Alignment(pos, 0.5),
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

// DIGITAL CLOCK ROLL-DOWN ANIMATED PRICE COUNTER WIDGET
class _DigitalClockRollCounter extends StatefulWidget {
  final double targetAmount;
  final TextStyle style;

  const _DigitalClockRollCounter({
    required this.targetAmount,
    required this.style,
  });

  @override
  State<_DigitalClockRollCounter> createState() => _DigitalClockRollCounterState();
}

class _DigitalClockRollCounterState extends State<_DigitalClockRollCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
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
        final progress = _controller.value;
        final currentVal = widget.targetAmount *
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutCubic,
            ).value;

        final formattedText = CurrencyUtils.formatINR(currentVal);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: List.generate(formattedText.length, (index) {
            final char = formattedText[index];
            final stagger = (index * 0.08).clamp(0.0, 0.4);
            final charProgress = ((progress - stagger) / (1.0 - stagger)).clamp(0.0, 1.0);
            final rollY = (1.0 - charProgress) * -1.2;

            return Transform.translate(
              offset: Offset(0, rollY * 20),
              child: Opacity(
                opacity: charProgress.clamp(0.1, 1.0),
                child: Text(
                  char,
                  style: widget.style,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ZOOM-IN ZOOM-OUT ANIMATION WIDGET FOR STICKERS
class _ZoomingWidget extends StatefulWidget {
  final Widget child;

  const _ZoomingWidget({required this.child});

  @override
  State<_ZoomingWidget> createState() => _ZoomingWidgetState();
}

class _ZoomingWidgetState extends State<_ZoomingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: widget.child,
    );
  }
}

// SHINING & PULSING POP-UP/DOWN SUBSCRIBE BUTTON WIDGET
class _ShiningPulsingSubscribeButton extends StatefulWidget {
  final MembershipPlan plan;
  final VoidCallback onPressed;

  const _ShiningPulsingSubscribeButton({
    required this.plan,
    required this.onPressed,
  });

  @override
  State<_ShiningPulsingSubscribeButton> createState() =>
      __ShiningPulsingSubscribeButtonState();
}

class __ShiningPulsingSubscribeButtonState
    extends State<_ShiningPulsingSubscribeButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shineController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _scaleAnim = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
      animation: Listenable.merge([_pulseController, _shineController]),
      builder: (context, child) {
        final shinePos = _shineController.value * 3.0 - 1.0;

        return ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha(140),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: widget.plan.accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: widget.onPressed,
                    icon: Icon(Icons.bolt_rounded, color: widget.plan.accentColor, size: 20),
                    label: Text(
                      'SUBSCRIBE NOW →',
                      style: TextStyle(
                        color: widget.plan.accentColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Button Light Streak Shine
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: const [
                              Colors.transparent,
                              Colors.white10,
                              Colors.white70,
                              Colors.white10,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                            begin: Alignment(shinePos - 1.0, -0.5),
                            end: Alignment(shinePos, 0.5),
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(color: Colors.white.withAlpha(1)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
