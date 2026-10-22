import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'About Bee Beeyond'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Color(0xFF312E81)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.amberAccent.withValues(alpha: 0.6),
                    width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x300F0C20),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
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
                    'BEE BEEYOND',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  const Text(
                    'Holistic Wellness, E-Learning & Healing Ecosystem',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Transforming lives worldwide through ancient Ayurvedic wisdom, Bach flower remedies, drugless therapies & digital innovation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFC7D2FE),
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'Version 1.0.0 • Certified Holistic Platform',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // IMPACT KPI METRIC COUNTERS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 3)),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricCounterItem(
                      number: '50,000+', label: 'Seekers Healed'),
                  _MetricCounterItem(
                      number: '120+', label: 'Certified Courses'),
                  _MetricCounterItem(number: '4.9 ⭐', label: 'User Rating'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MISSION & VISION CARD
            _buildSectionHeader(
                'Our Mission & Vision', Icons.lightbulb_outline_rounded),
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
                      offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMissionItem(
                    title: 'Empowering Self-Healing',
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

            // KEY ECOSYSTEM FEATURES SHOWCASE (SAFE COLUMN LAYOUT)
            _buildSectionHeader(
                'Platform Features & Capabilities', Icons.apps_rounded),
            const SizedBox(height: 10),

            const Row(
              children: [
                Expanded(
                  child: _FeatureShowcaseCard(
                    title: 'Certified Academy',
                    subtitle:
                        'Video lectures, study handbooks & ISO certificates.',
                    icon: Icons.school_rounded,
                    color: Color(0xFF6366F1),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _FeatureShowcaseCard(
                    title: 'Organic Store',
                    subtitle:
                        'Bach drops, herbal teas & 18% GST tax invoices.',
                    icon: Icons.shopping_bag_rounded,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const Row(
              children: [
                Expanded(
                  child: _FeatureShowcaseCard(
                    title: 'Practitioner Guidance',
                    subtitle: '1-on-1 consultations with experienced doctors.',
                    icon: Icons.support_agent_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _FeatureShowcaseCard(
                    title: 'VIP Pass Access',
                    subtitle: 'Free webinars, ebooks & priority doctor slots.',
                    icon: Icons.verified_user_rounded,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const Row(
              children: [
                Expanded(
                  child: _FeatureShowcaseCard(
                    title: '24/7 Digital Library',
                    subtitle: 'Binaural sleep audio, music & study notes.',
                    icon: Icons.library_books_rounded,
                    color: Color(0xFF0288D1),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _FeatureShowcaseCard(
                    title: '256-Bit SSL Gateway',
                    subtitle: 'Secured payments via Razorpay, UPI & Cards.',
                    icon: Icons.security_rounded,
                    color: Color(0xFFEC4899),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // CORE ETHICAL VALUES
            _buildSectionHeader(
                'Our Core Ethical Commitments', Icons.verified_rounded),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              ),
              child: Column(
                children: [
                  _buildCommitmentTile(
                      '🌿 100% Natural, Chemical-Free & Side-Effect Free Remedies'),
                  _buildCommitmentTile(
                      '📜 Government & ISO Recognized Completion Certificates'),
                  _buildCommitmentTile(
                      '🔒 Complete Privacy, Encrypted Payments & Data Protection'),
                  _buildCommitmentTile(
                      '🤝 Dedicated 24/7 Student & Customer Helpdesk Support'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // OFFICIAL CONTACT & FOOTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Connect with Bee Beeyond',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        onPressed: () =>
                            _launchUrl('https://metricstestingapp.xyz'),
                        icon: const Icon(Icons.language_rounded,
                            color: Colors.white, size: 16),
                        label: const Text('Website',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        onPressed: () =>
                            _launchUrl('mailto:support@beebeeyond.com'),
                        icon: const Icon(Icons.email_outlined,
                            color: AppColors.primary, size: 16),
                        label: const Text('Email Us',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    '📍 Mumbai, Maharashtra, India',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),

                  const Text(
                    '© 2025-2026 Bee Beeyond. All Rights Reserved.',
                    style: TextStyle(
                        fontSize: 10.5, color: AppColors.textHint),
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
}

class _MetricCounterItem extends StatelessWidget {
  final String number;
  final String label;

  const _MetricCounterItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
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
  }
}

class _FeatureShowcaseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _FeatureShowcaseCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
