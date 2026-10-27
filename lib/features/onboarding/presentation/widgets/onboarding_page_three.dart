import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPageThree extends StatelessWidget {
  const OnboardingPageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Sub-Tag Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE3F7E6), Color(0xFFF1FCF2), Color(0xFFEBF9EF)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFAEE2BA),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF006A37),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  'CERTIFIED LEARNING & WORKSHOPS',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF005229),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('✨', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main Headline
          RichText(
            text: TextSpan(
              text: 'Master ',
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                height: 1.25,
              ),
              children: [
                TextSpan(
                  text: 'Health & Wellness',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color(0xFF006A37),
                          Color(0xFF6E4F9A),
                          Color(0xFFB84F1A),
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 220, 20)),
                  ),
                ),
                TextSpan(
                  text: '\nWith Certified Courses',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Description Text inside soft paper card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEE7D8), width: 1.2),
            ),
            child: Text(
              'Explore 120+ accredited holistic modules, live interactive mentor workshops, and lifelong certification tracks designed for complete physical & mental rejuvenation.',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: const Color(0xFF475569),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Bento Highlights: 3 Artisan Metric Cards
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF9F5EC), Color(0xFFF4EEE1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2D8C4), width: 1.2),
            ),
            child: Row(
              children: [
                // Metric 1: Modules
                Expanded(
                  child: _buildBentoMetricCard(
                    icon: Icons.auto_stories_rounded,
                    iconBgGradient: const [Color(0xFFECDFDD), Color(0xFFF7F0FF)],
                    iconColor: const Color(0xFF6E4F9A),
                    borderColor: const Color(0xFFE6D8FA),
                    label: 'Modules',
                    value: '120+',
                    badgeText: 'Holistic',
                    badgeBg: const Color(0xFFEDDCFF),
                    badgeColor: const Color(0xFF563781),
                  ),
                ),
                const SizedBox(width: 8),

                // Metric 2: Rating
                Expanded(
                  child: _buildBentoMetricCard(
                    icon: Icons.hotel_class_rounded,
                    iconBgGradient: const [Color(0xFFFFE6D8), Color(0xFFFFF4EC)],
                    iconColor: const Color(0xFF9C3E00),
                    borderColor: const Color(0xFFFEDECB),
                    label: 'Rating',
                    value: '4.9 ★',
                    badgeText: '15k+ Reviews',
                    badgeBg: const Color(0xFFFDE9DE),
                    badgeColor: const Color(0xFF7B2F00),
                  ),
                ),
                const SizedBox(width: 8),

                // Metric 3: Study Cohorts
                Expanded(
                  child: _buildBentoMetricCard(
                    icon: Icons.groups_3_rounded,
                    iconBgGradient: const [Color(0xFFD6F7DC), Color(0xFFEDFCF0)],
                    iconColor: const Color(0xFF006A37),
                    borderColor: const Color(0xFFC4ECCB),
                    label: 'Study Cohorts',
                    value: '24x7',
                    badgeText: 'Live Global',
                    badgeBg: const Color(0xFF91F8AF),
                    badgeColor: const Color(0xFF005229),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Curated Course Pathways Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB84F1A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'WHAT YOU WILL DISCOVER',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7EA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB6E8C0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF006A37),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Accredited',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006A37),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Feature Card 1: Certified Workshops & Diplomas
          _buildOrnamentalCard(
            gradientColors: const [Color(0xFF6E4F9A), Color(0xFFDEC5FD)],
            icon: Icons.workspace_premium_rounded,
            badgeCornerIcon: '★',
            badgeCornerBg: const Color(0xFFD4982A),
            title: 'Certified Workshops & Diplomas',
            badgeText: 'Govt. Recognized',
            badgeBg: const Color(0xFFEDDCFF),
            badgeColor: const Color(0xFF563781),
            description:
                'Get certified in authentic Ayurveda, Vastu Shastra, Bach Flower remedies & Graphology under master practitioners.',
            borderColor: const Color(0xFFDFD5EE),
          ),

          const SizedBox(height: 12),

          // Feature Card 2: Video Lectures & Rich Materials
          _buildOrnamentalCard(
            gradientColors: const [Color(0xFF0F8548), Color(0xFFD9F5E3)],
            icon: Icons.play_circle_rounded,
            badgeCornerIcon: '📖',
            badgeCornerBg: const Color(0xFF006A37),
            title: 'Video Lectures & Rich Materials',
            badgeText: '4K & Offline',
            badgeBg: const Color(0xFFE5E8F4),
            badgeColor: const Color(0xFF3E4A40),
            description:
                'Access comprehensive multi-lingual video lessons, printable guided journals, and self-assessment wellness checklists anytime.',
            borderColor: const Color(0xFFD6E3DB),
          ),

          const SizedBox(height: 12),

          // Feature Card 3: Personal Mentor & Doctor Support
          _buildOrnamentalCard(
            gradientColors: const [Color(0xFFB84F1A), Color(0xFFFFEBD9)],
            icon: Icons.self_improvement_rounded,
            badgeCornerIcon: '🌿',
            badgeCornerBg: const Color(0xFFB84F1A),
            title: 'Personal Mentor & Doctor Support',
            badgeText: '1-on-1 Guidance',
            badgeBg: const Color(0xFF91F8AF),
            badgeColor: const Color(0xFF005229),
            description:
                'Direct voice & video Q&A support with experienced holistic lifestyle mentors, dietitians, and certified wellness guides.',
            borderColor: const Color(0xFFEDD7C8),
          ),

          const SizedBox(height: 20),

          // Mindful Wisdom Parchment Scroll Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEFBF6), Color(0xFFF8F3E8), Color(0xFFFCF9F2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE6D6B6), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD9C2), Color(0xFFFFECE0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF5B894)),
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: Color(0xFF9C3E00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'WISDOM EMBODIED',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF9C3E00),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('✦', style: TextStyle(color: Color(0xFFD4982A), fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"Learning to heal yourself is the first step toward illuminating the world around you."',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C303A),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBentoMetricCard({
    required IconData icon,
    required List<Color> iconBgGradient,
    required Color iconColor,
    required Color borderColor,
    required String label,
    required String value,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: iconBgGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnamentalCard({
    required List<Color> gradientColors,
    required IconData icon,
    required String badgeCornerIcon,
    required Color badgeCornerBg,
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required String description,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: badgeCornerBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeCornerIcon,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
