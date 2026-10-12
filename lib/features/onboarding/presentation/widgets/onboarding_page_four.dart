import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPageFour extends StatelessWidget {
  const OnboardingPageFour({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Counter Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.badgeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              '04/04',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Header Text
          Text(
            'Your Partner For\nA Healthier & Happier You',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Bee Beyond is your personal companion guiding you towards physical, mental & spiritual wellbeing.",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 18),

          // 4 Pillar Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGoalBadge(icon: Icons.favorite_rounded, label: 'Healthy Body', color: const Color(0xFFEF4444)),
              _buildGoalBadge(icon: Icons.psychology_rounded, label: 'Peaceful Mind', color: AppColors.primary),
              _buildGoalBadge(icon: Icons.eco_rounded, label: 'Better Lifestyle', color: const Color(0xFF10B981)),
              _buildGoalBadge(icon: Icons.auto_awesome_rounded, label: 'Spiritual Growth', color: const Color(0xFFF59E0B)),
            ],
          ),

          const SizedBox(height: 20),

          // Hero Sunrise Mountain Illustration Card
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF2F0FC),
                  Color(0xFFE8E5F8),
                  Color(0xFFF9F8FE),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x124B489B),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 16,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          AssetPaths.beeBeyondImage2,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.spa, size: 40, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bee Beyond',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 18,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.self_improvement_rounded,
                        size: 56,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Embrace Your Well-being Today',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGoalBadge({required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label.replaceAll(' ', '\n'),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
