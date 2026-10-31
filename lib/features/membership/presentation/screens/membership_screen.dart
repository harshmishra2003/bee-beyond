import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/expiry_manager_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../../../../core/services/razorpay_service.dart';
import 'package:intl/intl.dart';
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

  bool _isLottieActive = true;
  DateTime? _dataResponseTime;
  Timer? _postResponseTimer;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);

    _postResponseTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLottieActive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _postResponseTimer?.cancel();
    _razorpayService?.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _openMembershipCheckoutModal(MembershipPlanEntity plan) {
    context.push('${RoutePaths.membershipDetail}?id=${plan.id}', extra: plan);
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

  Widget _buildMembershipLottieLoadingOverlay() {
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
            Icons.card_membership_rounded,
            size: 80,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(membershipPlansProvider);
    final activePass = ref.watch(activePassProvider);

    if (_isLottieActive || (plansAsync.isLoading && !plansAsync.hasValue)) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9FE),
        body: _buildMembershipLottieLoadingOverlay(),
      );
    }

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
              if (activePass != null && !activePass.isExpired)
                _buildActivePassStatusCard(activePass)
              else
                _buildNoActivePassCard(),

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
                      return _buildFullSizeLightMembershipCard(plan, activePass);
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

  Widget _buildNoActivePassCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Color(0xD9D97706),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NO ACTIVE VIP MEMBERSHIP',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Unlock VIP Passes Below',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Choose a pass below to get flat discounts & VIP access.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              Expanded(
                child: Row(
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
                    Expanded(
                      child: Column(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

  void _showAlreadyActivePlanDialog(BuildContext context, UserPassSubscription pass) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Plan Already Active!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  children: [
                    Text(
                      pass.passName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF047857),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valid until: ${DateFormat('dd MMM yyyy, hh:mm a').format(pass.expiresAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                    Text(
                      'Time Remaining: ${pass.formattedLiveCountdown}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'You already hold an active subscription for this membership pass. You do not need to purchase it again while active.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Back / Close',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF475569),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF059669),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.push(RoutePaths.myMemberships);
                      },
                      child: Text(
                        'My Passes',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FULL-SIZE LIGHT THEME MEMBERSHIP CARD BUILDER
  Widget _buildFullSizeLightMembershipCard(
    MembershipPlanEntity plan,
    UserPassSubscription? activePass,
  ) {
    final isMatching = activePass != null && activePass.matchesPlan(plan.id, plan.slug);
    final isCurrentActive = isMatching && activePass.isActive;
    final isExpiringSoon = isMatching && activePass.isExpiringSoon;

    void handleCardTap() {
      if (isCurrentActive && !isExpiringSoon) {
        _showAlreadyActivePlanDialog(context, activePass);
      } else {
        context.push('${RoutePaths.membershipDetail}?id=${plan.id}', extra: plan);
      }
    }

    Color getBorderColor() {
      if (isExpiringSoon) return const Color(0xFFF59E0B);
      if (isCurrentActive) return const Color(0xFF10B981);
      return plan.cardThemeColor.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: handleCardTap,
      child: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: getBorderColor(),
          width: isCurrentActive ? 2.2 : (plan.isPopular ? 2.0 : 1.2),
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
              ShiningImageWrapper(
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
                  activePass: activePass,
                  onPressed: handleCardTap,
                ),
              ],
            ),
          ),
        ],
      ),
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
  final UserPassSubscription? activePass;
  final VoidCallback onPressed;

  const _ShiningPulsingSubscribeButton({
    required this.plan,
    required this.activePass,
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
    final pass = widget.activePass;
    final isMatching = pass != null && pass.matchesPlan(widget.plan.id, widget.plan.slug);
    final isCurrentActive = isMatching && pass.isActive;
    final isExpiringSoon = isMatching && pass.isExpiringSoon;
    final isCurrentExpired = isMatching && pass.isExpired;

    List<Color> gradientColors;
    String buttonText;
    IconData buttonIcon;

    if (isExpiringSoon || isCurrentExpired) {
      gradientColors = const [Color(0xFFD97706), Color(0xFFF59E0B)];
      buttonText = 'RENEW MEMBERSHIP PASS';
      buttonIcon = Icons.autorenew_rounded;
    } else if (isCurrentActive) {
      gradientColors = const [Color(0xFF047857), Color(0xFF10B981)];
      buttonText = 'CLAIMED ✓';
      buttonIcon = Icons.check_circle_rounded;
    } else {
      gradientColors = [
        widget.plan.cardThemeColor,
        widget.plan.cardThemeColor.withValues(alpha: 0.85),
      ];
      buttonText = 'BUY ${widget.plan.name.toUpperCase()} PASS';
      buttonIcon = Icons.arrow_forward_rounded;
    }

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
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.35),
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
                              buttonText,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(buttonIcon, size: 18),
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

// SHINING IMAGE WRAPPER WITH PERIODIC DIAGONAL LIGHT BEAM SWEEP
class ShiningImageWrapper extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ShiningImageWrapper({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
  });

  @override
  State<ShiningImageWrapper> createState() => _ShiningImageWrapperState();
}

class _ShiningImageWrapperState extends State<ShiningImageWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,

          // Periodic Diagonal Shining Light Glint Sweep
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              final val = _shimmerController.value;
              if (val > 0.45) return const SizedBox.shrink();

              final progress = val / 0.45;
              final alignX = -2.0 + progress * 4.0;

              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(alignX - 0.5, -1.0),
                        end: Alignment(alignX + 0.5, 1.0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.45),
                          Colors.white.withValues(alpha: 0.05),
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
