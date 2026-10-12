import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/receipt_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../../routing/route_paths.dart';

class EnrollmentReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const EnrollmentReceiptScreen({super.key, required this.data});

  ReceiptEntity _buildReceiptEntity() {
    final enrollmentId = data['enrollmentId'] ?? 'ENR-2025-9981';
    final studentName = data['studentName'] ?? 'Student Name';
    final courseTitle = data['courseTitle'] ?? 'Wellness Course';
    final coursePrice = (data['coursePrice'] as double?) ?? 2499.0;
    final email = data['email'] ?? 'student@gmail.com';
    final phone = data['phone'] ?? '+91 9876543210';
    final address = data['address'] ?? 'Mumbai, India';

    return ReceiptEntity(
      receiptId: enrollmentId,
      orderId: enrollmentId,
      title: courseTitle,
      type: 'COURSE',
      customerName: studentName,
      customerPhone: phone,
      customerEmail: email,
      deliveryAddress: address,
      items: [
        ReceiptItem(name: courseTitle, quantity: 1, unitPrice: coursePrice),
      ],
      subtotal: coursePrice,
      gstRate: 0.18,
      deliveryFee: 0.0,
      discount: 0.0,
      paymentMethod: 'UPI / Online Portal',
      date: DateTime.now(),
    );
  }

  void _downloadReceipt(BuildContext context) {
    ReceiptPdfService.downloadAndSaveReceiptPdf(context, _buildReceiptEntity());
  }

  void _shareReceipt(BuildContext context) {
    ReceiptPdfService.shareReceipt(context, _buildReceiptEntity());
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentId = data['enrollmentId'] ?? 'ENR-2025-9981';
    final studentName = data['studentName'] ?? 'Student Name';
    final courseTitle = data['courseTitle'] ?? 'Wellness Course';
    final courseCategory = data['courseCategory'] ?? 'Ayurveda';
    final coursePrice = (data['coursePrice'] as double?) ?? 2499.0;
    final email = data['email'] ?? 'student@gmail.com';
    final phone = data['phone'] ?? '+91 9876543210';
    final address = data['address'] ?? 'Mumbai, India';
    final profilePic = data['profilePic'] as String?;
    final date = data['date'] ?? '01 Mar 2025';

    final cgst = (coursePrice * 0.09);
    final sgst = (coursePrice * 0.09);
    final totalGst = cgst + sgst;
    final grandTotal = coursePrice + totalGst;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: CustomAppBar(
        title: 'Enrollment Receipt & Invoice',
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            onPressed: () => _downloadReceipt(context),
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
            onPressed: () => _shareReceipt(context),
            tooltip: 'Share Receipt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Success Confirmation Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Registration Confirmed & Paid!', style: AppTextStyles.titleMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text('Official student invoice & tax receipt generated.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Official Invoice Paper Card with Watermark
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('OFFICIAL TAX INVOICE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textHint, letterSpacing: 0.8)),
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

                      const Divider(height: 24, color: AppColors.divider),

                      // Student Details
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF2F0FC),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: ClipOval(
                              child: profilePic != null
                                  ? Image.asset(profilePic, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppColors.primary, size: 30))
                                  : const Icon(Icons.person, color: AppColors.primary, size: 30),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(studentName, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('$email • $phone', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24, color: AppColors.divider),

                      // Breakdown
                      _buildReceiptDetailRow('Enrolled Program:', courseTitle),
                      const SizedBox(height: 8),
                      _buildReceiptDetailRow('Course Base Fee:', CurrencyUtils.formatINR(coursePrice)),
                      const SizedBox(height: 8),
                      _buildReceiptDetailRow('CGST (9%):', CurrencyUtils.formatINR(cgst)),
                      const SizedBox(height: 8),
                      _buildReceiptDetailRow('SGST (9%):', CurrencyUtils.formatINR(sgst)),
                      const SizedBox(height: 8),
                      _buildReceiptDetailRow('Total Tax (18% GST):', CurrencyUtils.formatINR(totalGst)),
                      const SizedBox(height: 8),
                      _buildReceiptDetailRow('Payment Status:', 'PAID ✓ (Online Portal)', valueColor: AppColors.success),
                      const SizedBox(height: 8),
                      _buildReceiptDetailRow('Date & Time:', date),
                      const SizedBox(height: 8),
                      _buildReceiptDetailRow('Address:', address),

                      const Divider(height: 24, color: AppColors.divider),

                      // Grand Total Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL AMOUNT PAID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          Text(
                            CurrencyUtils.formatINR(grandTotal),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Stamp Footer
                      Row(
                        children: [
                          Image.asset(
                            AssetPaths.beeBeyondImage1,
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
                                Text('Certified Wellness & E-Learning Portal • GSTIN: 27BEEB1234F1Z0', style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // LIGHT THEME WATERMARK LOGO
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Opacity(
                        opacity: 0.06,
                        child: Image.asset(
                          AssetPaths.beeBeyondImage1,
                          width: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.spa_rounded,
                            size: 160,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Navigation Actions
            ThreeDButton(
              text: 'Go to My Joined Courses →',
              fontSize: 15,
              padding: const EdgeInsets.symmetric(vertical: 13),
              onPressed: () => context.go(RoutePaths.joinedCourses),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadReceipt(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    icon: const Icon(Icons.download_rounded, color: AppColors.primary, size: 18),
                    label: const Text('Download PDF', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(RoutePaths.receipts),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 18),
                    label: const Text('All Invoices', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ),
              ],
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
          width: 125,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
