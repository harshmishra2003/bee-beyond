import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({super.key});

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
              '02/04',
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
            'Master Health & Wellness\nWith Certified Courses',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Explore 120+ modules, video lectures, and interactive study groups.',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          // Metric Badges Graphic Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricChip(
                  icon: Icons.menu_book_rounded,
                  iconColor: AppColors.primary,
                  title: 'Modules',
                  value: '120+',
                ),
                _buildMetricChip(
                  icon: Icons.star_rounded,
                  iconColor: Colors.amber,
                  title: 'Rating',
                  value: '4.9 ★',
                ),
                _buildMetricChip(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Study Groups',
                  value: 'Live 24x7',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3 Feature List Items
          _buildFeatureTile(
            icon: Icons.school_outlined,
            badgeColor: AppColors.primary,
            title: 'Certified Workshops & Diplomas',
            subtitle: 'Get certified in Ayurveda, Vastu, Bach Flower & Graphology.',
          ),
          const SizedBox(height: 12),
          _buildFeatureTile(
            icon: Icons.ondemand_video_outlined,
            badgeColor: const Color(0xFF0288D1),
            title: 'Video Lectures & Materials',
            subtitle: 'Access comprehensive study materials anytime, anywhere.',
          ),
          const SizedBox(height: 12),
          _buildFeatureTile(
            icon: Icons.support_agent_outlined,
            badgeColor: const Color(0xFF10B981),
            title: 'Personal Mentor Guidance',
            subtitle: 'Direct Q&A support with experienced holistic practitioners.',
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
