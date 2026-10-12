import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPageThree extends StatelessWidget {
  const OnboardingPageThree({super.key});

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
              '03/04',
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
            'Harmonize Your Mind &\nEnergy Balance',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Comprehensive therapies to balance emotions, energy, and mental peace.',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          // Quick Therapy Pills Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTherapyPill(icon: Icons.local_florist_outlined, label: 'Bach Flower', color: const Color(0xFFE91E63)),
              _buildTherapyPill(icon: Icons.home_work_outlined, label: 'Vastu Shastra', color: AppColors.primary),
              _buildTherapyPill(icon: Icons.edit_note_outlined, label: 'Graphology', color: const Color(0xFF0288D1)),
            ],
          ),

          const SizedBox(height: 20),

          // 4 Feature List Items
          _buildFeatureTile(
            icon: Icons.psychology_outlined,
            badgeColor: AppColors.primary,
            title: 'Emotional & Mind Release',
            subtitle: 'Breathwork and natural flower remedies to relieve stress.',
          ),
          const SizedBox(height: 12),
          _buildFeatureTile(
            icon: Icons.home_work_outlined,
            badgeColor: const Color(0xFFF59E0B),
            title: 'Vastu & Positive Energy',
            subtitle: 'Harmonize your living and work space energy.',
          ),
          const SizedBox(height: 12),
          _buildFeatureTile(
            icon: Icons.fingerprint_outlined,
            badgeColor: const Color(0xFF10B981),
            title: 'DMIT & Personality Coaching',
            subtitle: 'Unlock hidden potential and innate talents.',
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTherapyPill({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color badgeColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: badgeColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
