import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/expiry_manager_service.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../orders/presentation/providers/receipt_provider.dart';
import '../../../orders/presentation/screens/receipt_preview_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _subscribePlan(MembershipPlanEntity plan) {
    final currentUser = ref.read(authStateProvider).user;
    final customerName = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'Bee Beeyond Member';
    final customerPhone = currentUser?.phone.isNotEmpty == true ? currentUser!.phone : 'Self-Service Pass';
    final customerEmail = currentUser?.email.isNotEmpty == true ? currentUser!.email : 'member@beebeeyond.com';

    final receiptId = 'REC-2025-${(1000 + plan.id.hashCode % 8999).abs()}';
    final orderId = 'MBR-2025-${(5000 + plan.id.hashCode % 4999).abs()}';

    final newReceipt = ReceiptEntity(
      receiptId: receiptId,
      orderId: orderId,
      title: plan.displayName,
      type: 'MEMBERSHIP',
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      deliveryAddress: 'Online VIP Membership Access Pass (Bee Beeyond Portal)',
      items: [
        ReceiptItem(name: plan.displayName, quantity: 1, unitPrice: plan.price),
      ],
      subtotal: plan.price,
      gstRate: 0.18,
      deliveryFee: 0.0,
      discount: 0.0,
      paymentMethod: 'UPI / Card (Online)',
      date: DateTime.now(),
    );

    ref.read(receiptsProvider.notifier).addReceipt(newReceipt);

    // Activate the pass in ActivePassNotifier
    ref.read(activePassProvider.notifier).activatePass(
          passId: plan.id,
          passName: plan.displayName,
          slug: plan.slug,
          durationYears: plan.accessDuration > 0 ? plan.accessDuration : 1,
        );

    AppAlertManager.showFloatingToast(
      context,
      title: 'VIP Pass Activated!',
      message: 'Subscribed to ${plan.displayName} successfully',
      icon: Icons.stars_rounded,
      backgroundColor: const Color(0xFF0F172A),
      accentColor: const Color(0xFF10B981),
      actionLabel: 'RECEIPT',
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

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(membershipPlansProvider);
    final activePass = ref.watch(activePassProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'VIP Membership Cards'),
      body: RefreshIndicator(
        color: const Color(0xFF312E81),
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

              // MEMBERSHIP CARDS LIST (DYNAMIC API RESPONSE)
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
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return _buildShimmeringMembershipCard(plan);
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
    Color statusColor = const Color(0xFF10B981); // Emerald for active
    if (activePass.status == AccessStatus.expiringSoon) {
      statusColor = const Color(0xFFF59E0B); // Amber for expiring soon
    } else if (activePass.isExpired) {
      statusColor = const Color(0xFFEF4444); // Red for expired
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.12),
            blurRadius: 12,
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
                      color: statusColor.withValues(alpha: 0.15),
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
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
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

          // Subscription Duration Progress Bar
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
          height: 220,
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
              CircularProgressIndicator(color: Color(0xFF312E81)),
              SizedBox(height: 12),
              Text(
                'Fetching VIP Membership Plans...',
                style: TextStyle(
                  color: Color(0xFF312E81),
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
          const Icon(Icons.workspace_premium_rounded, size: 48, color: Color(0xFF312E81)),
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
              backgroundColor: const Color(0xFF312E81),
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
              backgroundColor: const Color(0xFF312E81),
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

  // SHIMMERING METALLIC CARD BUILDER
  Widget _buildShimmeringMembershipCard(MembershipPlanEntity plan) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerPos = Tween<double>(begin: -1.3, end: 2.3).transform(
          CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine).value,
        );

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
                            plan.displayTagline,
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
                                child: Text(
                                  plan.displayBadgeText,
                                  style: const TextStyle(color: Color(0xFF78350F), fontSize: 9, fontWeight: FontWeight.w900),
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
                    plan.displayName,
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
                        '/ ${plan.durationLabel}',
                        style: TextStyle(color: plan.textColor.withAlpha(200), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: Colors.white30, height: 1),
                  ),

                  // Benefits Checklist
                  ...plan.features.map((b) => Padding(
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
                        stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
                        begin: Alignment(shimmerPos - 1.0, -0.6),
                        end: Alignment(shimmerPos, 0.6),
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
        final pulseScale = 1.0 + (_pulseController.value * 0.03);

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
                            'CLAIM ${widget.plan.displayTagline}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
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
                                      Colors.white.withValues(alpha: 0.9),
                                      widget.plan.isPopular
                                          ? Colors.white.withValues(alpha: 0.95)
                                          : Colors.amberAccent.withValues(alpha: 0.7),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                    stops: const [0.0, 0.35, 0.65, 1.0],
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
