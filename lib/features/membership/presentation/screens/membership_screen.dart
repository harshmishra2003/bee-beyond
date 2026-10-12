import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Membership & Healing Pass'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x284B489B),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium_rounded, size: 60, color: Color(0xFFFFD700)),
                  const SizedBox(height: 12),
                  Text(
                    'Bee Beyond Healing Pass',
                    style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock unlimited digital library access, 1-on-1 practitioner consultation discounts & weekly live Q&A webinars.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ThreeDButton(
                    text: 'Join Annual Pass (₹1,999/yr)',
                    color: Colors.white,
                    textColor: AppColors.primary,
                    shadowColor: const Color(0xFF383577),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membership order initiated!')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Benefits Checklist
            _buildBenefitTile(
              icon: Icons.check_circle_rounded,
              title: 'Unlimited Digital Library',
              subtitle: 'Full access to 100+ audio tracks, PDF charts & video masterclasses.',
            ),
            const SizedBox(height: 12),
            _buildBenefitTile(
              icon: Icons.check_circle_rounded,
              title: 'Special Consultation Discounts',
              subtitle: '20% off on private Vastu, Doctor & Counseling sessions.',
            ),
            const SizedBox(height: 12),
            _buildBenefitTile(
              icon: Icons.check_circle_rounded,
              title: 'Exclusive WhatsApp Community',
              subtitle: 'Direct Q&A access with certified senior practitioners.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x104B489B),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
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
}
