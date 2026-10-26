import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Future<void> _launchUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        AppAlertManager.showFloatingToast(
          context,
          title: 'Could Not Open Link',
          message: 'Unable to open $urlStr',
          icon: Icons.link_off_rounded,
          backgroundColor: const Color(0xFF0F172A),
          accentColor: const Color(0xFFEF4444),
        );
      }
    }
  }

  Future<void> _launchInstagram() async {
    const handles = ['bee.beyonnd', 'beebeyonnd.in', 'beebeeyond'];

    // 1. Try opening directly in Instagram Native App
    for (final handle in handles) {
      try {
        final appUri = Uri.parse('instagram://user?username=$handle');
        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    // 2. Fallback: Open profile in external web browser
    for (final handle in handles) {
      try {
        final webUri = Uri.parse('https://www.instagram.com/$handle/');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'About Bee Beyonnd'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // HERO BRAND BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F0C20),
                    Color(0xFF1E1B4B),
                    Color(0xFF312E81),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.amberAccent.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x300F0C20),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Emblem
                  Image.asset(
                    AssetPaths.beeBeyondEmblem,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.spa_rounded,
                      size: 64,
                      color: Colors.amberAccent,
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'BEE BEYONND',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  const Text(
                    'Steps Towards Mental and Physical Well-Being',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Transforming lives worldwide through ancient Ayurvedic wisdom, Bach flower remedies, Vastu Shastra, drugless therapies & ISO certified digital education.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFC7D2FE),
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'Version 2.5.0 • Certified Holistic Portal • GSTIN: 27AAQPS5062E1ZD',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ANIMATED IMPACT KPI METRIC COUNTERS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AnimatedMetricCounter(
                    targetValue: 50000,
                    suffix: '+',
                    label: 'Seekers Healed',
                  ),
                  _AnimatedMetricCounter(
                    targetValue: 120,
                    suffix: '+',
                    label: 'Certified Courses',
                  ),
                  _AnimatedMetricCounter(
                    targetValue: 4.9,
                    suffix: ' ⭐',
                    label: 'User Rating',
                    isDecimal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MISSION & VISION CARD
            _buildSectionHeader('Our Mission & Vision', Icons.lightbulb_outline_rounded),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMissionItem(
                    title: 'Empowering Self-Healing & Well-Being',
                    description:
                        'To educate and equip individuals with natural, chemical-free, drugless remedies for physical, mental, and emotional harmony.',
                    icon: Icons.nature_people_rounded,
                    color: const Color(0xFF059669),
                  ),
                  const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  _buildMissionItem(
                    title: 'Global Certified Practitioners',
                    description:
                        'To train 1,000,000+ certified practitioners in Prakriti analysis, Bach flower therapy, Vastu Shastra, and mind-body balancing.',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF4338CA),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FEATURED COURSES & SERVICES CATALOGUE SHOWCASE (WITH IMAGES)
            _buildSectionHeader('Services & Course Catalogues', Icons.collections_bookmark_rounded),
            const SizedBox(height: 10),

            // CATALOGUE IMAGE CARDS GRID
            _buildCatalogueCard(
              title: 'Ancient Healing & Drugless Therapy',
              subtitle: 'Masterclasses on Prakriti analysis, Marma therapy & Ayurvedic lifestyle.',
              imagePath: AssetPaths.ancientHealing,
              badgeText: 'Featured Course',
              badgeColor: const Color(0xFF6366F1),
            ),

            const SizedBox(height: 12),

            _buildCatalogueCard(
              title: 'Bach Flower Remedies & Emotional Healing',
              subtitle: '38 Flower essences for anxiety, stress relief, and emotional balance.',
              imagePath: AssetPaths.bachFlower,
              badgeText: 'Popular Therapy',
              badgeColor: const Color(0xFF10B981),
            ),

            const SizedBox(height: 12),

            _buildCatalogueCard(
              title: 'Vastu Shastra & Directional Harmony',
              subtitle: 'Scientific Vastu analysis for homes, offices & positive energy flow.',
              imagePath: AssetPaths.vastu,
              badgeText: 'Expert Consultation',
              badgeColor: const Color(0xFFF59E0B),
            ),

            const SizedBox(height: 24),

            // CORE ETHICAL COMMITMENTS
            _buildSectionHeader('Our Core Ethical Commitments', Icons.verified_rounded),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCommitmentTile('🌿 100% Natural, Chemical-Free & Side-Effect Free Remedies'),
                  _buildCommitmentTile('📜 Government & ISO Recognized Completion Certificates'),
                  _buildCommitmentTile('🔒 Complete Privacy, Encrypted Payments & Data Protection'),
                  _buildCommitmentTile('🤝 Dedicated 24/7 Student & Customer Helpdesk Support'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // OFFICIAL CONTACT DETAILS & ADDRESS
            _buildSectionHeader('Official Address & Contact Info', Icons.business_rounded),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildContactInfoRow(
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Office Address',
                    detail: 'Dotom Isle, Jankalyan Nagar, Malad West, Mumbai - 400095, Maharashtra, India',
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _buildContactInfoRow(
                    icon: Icons.phone_android_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: 'Primary Phone',
                    detail: '+91 8850920901',
                    onTap: () => _launchUrl('tel:+918850920901'),
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _buildContactInfoRow(
                    icon: Icons.headset_mic_rounded,
                    iconColor: const Color(0xFF6366F1),
                    title: 'Alternate Helpline',
                    detail: '+91 9892711391',
                    onTap: () => _launchUrl('tel:+919892711391'),
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _buildContactInfoRow(
                    icon: Icons.email_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Email Support',
                    detail: 'beebeeyonnd5@gmail.com',
                    onTap: () => _launchUrl('mailto:beebeeyonnd5@gmail.com'),
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _buildContactInfoRow(
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFFD97706),
                    title: 'GSTIN Registration',
                    detail: '27AAQPS5062E1ZD (Government Tax Recognized)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CLICKABLE STANDALONE CIRCULAR SOCIAL MEDIA ICONS
            _buildSectionHeader('Connect With Bee Beyonnd', Icons.share_rounded),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Join Our Social Healing Community',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap any icon to visit our official social channels',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),

                  // STANDALONE CIRCULAR SOCIAL ICON BADGES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // WHATSAPP
                      _SocialIconBadge(
                        label: 'Chat on WhatsApp',
                        imageAsset: AssetPaths.whatsappIcon,
                        fallbackIcon: Icons.chat_rounded,
                        gradientColors: const [Color(0xFF25D366), Color(0xFF128C7E)],
                        onTap: () => _launchUrl('https://wa.me/919967326151?text=Hello%20Bee%20Beyonnd'),
                      ),

                      // INSTAGRAM
                      _SocialIconBadge(
                        label: 'Follow on Instagram',
                        imageAsset: AssetPaths.instagramIcon,
                        fallbackIcon: Icons.camera_alt_rounded,
                        gradientColors: const [Color(0xFFE4405F), Color(0xFFC13584), Color(0xFF833AB4)],
                        onTap: _launchInstagram,
                      ),

                      // LINKEDIN
                      _SocialIconBadge(
                        label: 'Connect on LinkedIn',
                        imageAsset: AssetPaths.linkedinIcon,
                        fallbackIcon: Icons.business_center_rounded,
                        gradientColors: const [Color(0xFF0077B5), Color(0xFF00A0DC)],
                        onTap: () => _launchUrl('https://www.linkedin.com/company/bee-beyonnd/'),
                      ),

                      // FACEBOOK
                      _SocialIconBadge(
                        label: 'Follow on Facebook',
                        fallbackIcon: Icons.facebook_rounded,
                        gradientColors: const [Color(0xFF1877F2), Color(0xFF3B5998)],
                        onTap: () => _launchUrl('https://www.facebook.com/share/1XL3i9DhC8/'),
                      ),

                      // WEBSITE
                      _SocialIconBadge(
                        label: 'Visit Official Website',
                        fallbackIcon: Icons.language_rounded,
                        gradientColors: const [Color(0xFF0F0C20), Color(0xFF312E81)],
                        onTap: () => _launchUrl('https://beebeyonnd.in/'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    '📍 Malad West, Mumbai, Maharashtra, India',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  const Text(
                    '© 2025-2026 Bee Beyonnd. All Rights Reserved.',
                    style: TextStyle(fontSize: 10.5, color: AppColors.textHint),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogueCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: const Color(0xFFEEF2FF),
                    child: const Center(
                      child: Icon(Icons.spa_rounded, color: AppColors.primary, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitmentTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String detail,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: onTap != null ? AppColors.primary : const Color(0xFF0F172A),
                    decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.arrow_outward_rounded, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }
}

// ANIMATED NUMERIC METRIC COUNTER
class _AnimatedMetricCounter extends StatelessWidget {
  final double targetValue;
  final String suffix;
  final String label;
  final bool isDecimal;

  const _AnimatedMetricCounter({
    required this.targetValue,
    required this.suffix,
    required this.label,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetValue),
      duration: const Duration(milliseconds: 2200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        String formattedNumber;
        if (isDecimal) {
          formattedNumber = value.toStringAsFixed(1);
        } else {
          final intVal = value.toInt();
          formattedNumber = intVal >= 1000
              ? '${(intVal ~/ 1000)},${(intVal % 1000).toString().padLeft(3, '0')}'
              : '$intVal';
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$formattedNumber$suffix',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

// STANDALONE CIRCULAR GLOWING SOCIAL ICON BADGE
class _SocialIconBadge extends StatelessWidget {
  final String label;
  final String? imageAsset;
  final IconData? fallbackIcon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _SocialIconBadge({
    required this.label,
    this.imageAsset,
    this.fallbackIcon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        fallbackIcon ?? Icons.link_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  : Icon(
                      fallbackIcon ?? Icons.link_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
