import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/membership/presentation/providers/expiry_provider.dart';
import '../../routing/route_paths.dart';
import '../constants/asset_paths.dart';
import '../theme/app_colors.dart';

/// A context-aware feature wrapper.
/// Displays a branded VIP Membership Lock Guard Screen if the user lacks an active VIP pass.
class MembershipAccessGuard extends ConsumerStatefulWidget {
  final Widget child;
  final String featureName;
  final String featureDescription;
  final IconData? featureIcon;
  final List<String>? highlightPerks;

  const MembershipAccessGuard({
    super.key,
    required this.child,
    required this.featureName,
    this.featureDescription = 'audio tracks, video lectures, eBooks & consultations',
    this.featureIcon,
    this.highlightPerks,
  });

  @override
  ConsumerState<MembershipAccessGuard> createState() => _MembershipAccessGuardState();
}

class _MembershipAccessGuardState extends ConsumerState<MembershipAccessGuard> {
  static const LinearGradient logoFrameGradient = LinearGradient(
    colors: [
      Color(0xFF8B5CF6), // Royal Purple
      Color(0xFFEC4899), // Neon Pink
      Color(0xFF10B981), // Emerald Green
      Color(0xFFF59E0B), // Saffron Amber
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final activePass = ref.watch(activePassProvider);
    final isUnlocked = activePass != null && !activePass.isExpired;

    // Render feature directly if user has an active VIP pass
    if (isUnlocked) {
      return widget.child;
    }

    // Render Branded VIP Membership Lock Guard Screen
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. CENTER BRANDING EMBLEM LOGO WITH MULTI-COLOUR GLOWING FRAME
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(3.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: logoFrameGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x358B5CF6),
                        blurRadius: 20,
                        spreadRadius: 3,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      AssetPaths.beeBeyondEmblem,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.spa_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // BRAND NAME TYPOGRAPHY
                Text(
                  'BEE BEYONND',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                    color: const Color(0xFF280253),
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDDCFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, size: 14, color: Color(0xFF6E4F9A)),
                      const SizedBox(width: 4),
                      Text(
                        'VIP MEMBERSHIP REQUIRED',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: const Color(0xFF563781),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // FEATURE UNLOCK TITLE
                Text(
                  'Unlock ${widget.featureName} 👑',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.epilogue(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.featureDescription.isNotEmpty
                      ? widget.featureDescription
                      : 'Activate a Bee Beyonnd VIP Pass to get unlimited 24/7 reading, listening & streaming access across all features!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),

                // HIGHLIGHT PERKS BOX
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: (widget.highlightPerks ??
                        const [
                          'Unlimited 24/7 Reading & Listening Access',
                          '100% Certified & Consecrated Sacred Content',
                          'Exclusive VIP Discounts on Services & Products',
                          'Direct Priority Q&A Forum Support',
                        ])
                        .map((perk) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.5),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDCFCE7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      perk,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 28),

                // PRIMARY CTA BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E4F9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0x506E4F9A),
                    ),
                    onPressed: () {
                      context.push(RoutePaths.membership);
                    },
                    icon: const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 22),
                    label: Text(
                      'EXPLORE VIP MEMBERSHIP PASSES',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // BACK BUTTON
                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.go(RoutePaths.home);
                    }
                  },
                  child: Text(
                    'Go Back to Home',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
