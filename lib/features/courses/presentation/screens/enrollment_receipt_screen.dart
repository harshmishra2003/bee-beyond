import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../../routing/route_paths.dart';

class EnrollmentReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const EnrollmentReceiptScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final enrollmentId = data['enrollmentId'] ?? 'ENR-2025-9981';
    final studentName = data['studentName'] ?? 'Student Name';
    final courseTitle = data['courseTitle'] ?? 'Wellness Course';
    final courseCategory = data['courseCategory'] ?? 'Ayurveda';
    final coursePrice = (data['coursePrice'] as double?) ?? 8999.0;
    final email = data['email'] ?? 'student@gmail.com';
    final phone = data['phone'] ?? '+91 9876543210';
    final address = data['address'] ?? 'Mumbai, India';
    final profilePic = data['profilePic'] as String?;
    final date = data['date'] ?? '01 Mar 2025';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Enrollment Receipt'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Success Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Course Registration Confirmed!', style: AppTextStyles.titleMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text('Official student record has been generated.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Official Invoice Receipt Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x184B489B),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STUDENT REGISTRATION RECEIPT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textHint, letterSpacing: 0.8)),
                          const SizedBox(height: 2),
                          Text(enrollmentId, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          courseCategory,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 28, color: AppColors.divider),

                  // Student Details Row
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF2F0FC),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: ClipOval(
                          child: profilePic != null
                              ? Image.asset(profilePic, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppColors.primary, size: 32))
                              : const Icon(Icons.person, color: AppColors.primary, size: 32),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(studentName, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 28, color: AppColors.divider),

                  // Course & Payment Details
                  _buildReceiptDetailRow('Enrolled Course:', courseTitle),
                  const SizedBox(height: 8),
                  _buildReceiptDetailRow('Registration Fee:', CurrencyUtils.formatINR(coursePrice)),
                  const SizedBox(height: 8),
                  _buildReceiptDetailRow('Payment Status:', 'PAID (Online Enrollment)', valueColor: AppColors.success),
                  const SizedBox(height: 8),
                  _buildReceiptDetailRow('Date & Time:', date),
                  const SizedBox(height: 8),
                  _buildReceiptDetailRow('Student Address:', address),

                  const Divider(height: 28, color: AppColors.divider),

                  // Stamp / Verification Footer
                  Row(
                    children: [
                      Image.asset(
                        AssetPaths.beeBeyondImage2,
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.verified, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bee Beyond Holistic Learning Academy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text('Certified Wellness & E-Learning Portal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            ThreeDButton(
              text: 'Go to My Joined Courses →',
              fontSize: 15,
              padding: const EdgeInsets.symmetric(vertical: 13),
              onPressed: () => context.go(RoutePaths.joinedCourses),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt PDF saved to downloads!'), backgroundColor: AppColors.primary),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Download Official PDF Receipt', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13.5)),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12.5, color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
