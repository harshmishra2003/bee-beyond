import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/receipt_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../../routing/route_paths.dart';
import '../../domain/entities/receipt_entity.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final ReceiptEntity receipt;

  const ReceiptPreviewScreen({super.key, required this.receipt});

  static const Color greenPrimary = Color(0xFF12683A);
  static const Color greenLightBg = Color(0xFFE2EFE8);
  static const Color greyBgBox = Color(0xFFF2F5F3);
  static const Color borderColor = Color(0xFFCBD5E1);

  void _downloadReceipt(BuildContext context) {
    ReceiptPdfService.downloadAndSaveReceiptPdf(context, receipt);
  }

  void _shareReceipt(BuildContext context) {
    ReceiptPdfService.shareReceipt(context, receipt);
  }

  String get _bannerTitle {
    switch (receipt.type.toUpperCase()) {
      case 'COURSE':
        return 'Registration Confirmed & Paid!';
      case 'MEMBERSHIP':
      case 'SERVICE':
        return 'VIP Pass Activated & Paid!';
      case 'PRODUCT':
        return 'Order Confirmed & Paid!';
      default:
        return 'Payment Received & Confirmed!';
    }
  }

  String get _bannerSubtitle {
    switch (receipt.type.toUpperCase()) {
      case 'COURSE':
        return 'Official student invoice & tax receipt generated.';
      case 'MEMBERSHIP':
      case 'SERVICE':
        return 'Official membership invoice & tax pass generated.';
      case 'PRODUCT':
        return 'Official order invoice & delivery receipt generated.';
      default:
        return 'Official tax invoice & receipt generated.';
    }
  }

  String get _primaryButtonText {
    switch (receipt.type.toUpperCase()) {
      case 'COURSE':
        return 'My Courses →';
      case 'MEMBERSHIP':
      case 'SERVICE':
        return 'My Memberships →';
      case 'PRODUCT':
        return 'My Orders →';
      default:
        return 'My Purchases →';
    }
  }

  void _onPrimaryAction(BuildContext context) {
    switch (receipt.type.toUpperCase()) {
      case 'COURSE':
        context.go(RoutePaths.joinedCourses);
        break;
      case 'MEMBERSHIP':
      case 'SERVICE':
        context.go(RoutePaths.myMemberships);
        break;
      case 'PRODUCT':
        context.go(RoutePaths.orders);
        break;
      default:
        context.go(RoutePaths.receipts);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(receipt.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: CustomAppBar(
        title: 'Tax Invoice & Receipt',
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            onPressed: () => _downloadReceipt(context),
            tooltip: 'Download Receipt PDF',
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
            // SUCCESS CONFIRMATION BANNER
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _bannerTitle,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _bannerSubtitle,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // OFFICIAL INVOICE CARD MATCHING TEMPLATE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.2),
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
                  // 1. BRANDING HEADER ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Emblem Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: greenLightBg,
                          border: Border.all(color: greenPrimary, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          AssetPaths.beeBeyondEmblem,
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('BEE', style: TextStyle(fontWeight: FontWeight.bold, color: greenPrimary, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Company Contact Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'BEE BEYONND',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: greenPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Steps Towards Mental and Physical Well-Being',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Office: Dotom Isle, Jankalyan Nagar, Malad West, Mumbai - 400095',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 8, color: Color(0xFF64748B)),
                            ),
                            const Text(
                              'GSTIN: 27AAQPS5062E1ZD',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const Text(
                              'Email: beebeeyonnd5@gmail.com',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 8, color: Color(0xFF64748B)),
                            ),
                            const Text(
                              'Contact: 8850920901 | Alternate: 9892711391 | WhatsApp: 9967326151',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 8, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Container(height: 2, color: greenPrimary),
                  const SizedBox(height: 12),

                  // 2. INVOICE TITLE & META GRID BOX
                  const Text(
                    'INVOICE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: greyBgBox,
                      border: Border.all(color: borderColor, width: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMetaRow('Invoice No.', receipt.receiptId),
                              const SizedBox(height: 4),
                              _buildMetaRow('Due Date', dateStr),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMetaRow('Invoice Date', dateStr),
                              const SizedBox(height: 4),
                              _buildMetaRow('Place of Supply', 'Maharashtra (27)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. BILL TO & CUSTOMER DETAILS GRID BOX
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        // Title Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          color: greyBgBox,
                          child: const Row(
                            children: [
                              Expanded(
                                child: Text('BILL TO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: greenPrimary)),
                              ),
                              Expanded(
                                child: Text('Customer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: greenPrimary)),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: borderColor),

                        // Info Body
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Customer / Company Name:', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                    Text(receipt.customerName, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                    const SizedBox(height: 6),
                                    const Text('Billing Address:', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                    Text(receipt.deliveryAddress, style: const TextStyle(fontSize: 9.5, color: Color(0xFF1E293B))),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMetaRow('Phone:', receipt.customerPhone),
                                    const SizedBox(height: 4),
                                    _buildMetaRow('Email:', receipt.customerEmail),
                                    const SizedBox(height: 4),
                                    _buildMetaRow('GSTIN (if applicable):', 'URP (Unregistered)'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. ITEMS TABLE
                  Table(
                    border: TableBorder.all(color: borderColor, width: 0.8),
                    columnWidths: const {
                      0: FixedColumnWidth(30),
                      1: FlexColumnWidth(3),
                      2: FixedColumnWidth(36),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.2),
                    },
                    children: [
                      // Header Row
                      TableRow(
                        decoration: const BoxDecoration(color: greenPrimary),
                        children: [
                          _buildTableCell('Sr.', isHeader: true),
                          _buildTableCell('Description / Service', isHeader: true),
                          _buildTableCell('Qty', isHeader: true, alignCenter: true),
                          _buildTableCell('Rate (₹)', isHeader: true, alignRight: true),
                          _buildTableCell('Amount (₹)', isHeader: true, alignRight: true),
                        ],
                      ),

                      // Dynamic Item Rows
                      ...List.generate(receipt.items.length < 5 ? 5 : receipt.items.length, (index) {
                        if (index < receipt.items.length) {
                          final item = receipt.items[index];
                          return TableRow(
                            children: [
                              _buildTableCell('${index + 1}'),
                              _buildTableCell(item.name, isBold: true),
                              _buildTableCell('${item.quantity}', alignCenter: true),
                              _buildTableCell(CurrencyUtils.formatINR(item.unitPrice), alignRight: true),
                              _buildTableCell(CurrencyUtils.formatINR(item.totalPrice), alignRight: true, isBold: true),
                            ],
                          );
                        } else {
                          // Padding Empty Rows to match template proportions
                          return TableRow(
                            children: [
                              _buildTableCell(''),
                              _buildTableCell(''),
                              _buildTableCell(''),
                              _buildTableCell(''),
                              _buildTableCell(''),
                            ],
                          );
                        }
                      }),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 5. NOTES & CALCULATION SUMMARY
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Notes Box
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Notes / Payment Terms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text('Paid via ${receipt.paymentMethod} • Ref #${receipt.orderId}', style: const TextStyle(fontSize: 9, color: Color(0xFF334155))),
                            const SizedBox(height: 2),
                            const Text('Official digital receipt issued by Bee Beyonnd.', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            const Text('Thank you for choosing Bee Beyonnd.', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: greenPrimary)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right Calculation Table
                      Expanded(
                        flex: 4,
                        child: Table(
                          border: TableBorder.all(color: borderColor, width: 0.8),
                          children: [
                            _buildSummaryRow('Subtotal', CurrencyUtils.formatINR(receipt.subtotal)),
                            if (receipt.discount > 0)
                              _buildSummaryRow('Discount (if any)', '-${CurrencyUtils.formatINR(receipt.discount)}'),
                            _buildSummaryRow('Tax / GST (18%)', CurrencyUtils.formatINR(receipt.totalGst)),
                            _buildSummaryRow('GRAND TOTAL', CurrencyUtils.formatINR(receipt.grandTotal), isHighlighted: true),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 6. PAYMENT DETAILS & SIGNATURE
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Details UPI / Bank Transfer:',
                              style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B)),
                            ),
                            Text(
                              'beebeeyond@okaxis / HDFC Bank',
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Authorised Signature:',
                              style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B)),
                            ),
                            Text(
                              'Bee Beyonnd (Digitally Signed)',
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: borderColor),
                  const SizedBox(height: 8),

                  // 7. FOOTER SOCIAL LINKS
                  const Center(
                    child: Column(
                      children: [
                        Text('Connect with Bee Beyonnd', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: greenPrimary)),
                        SizedBox(height: 2),
                        Text('LinkedIn  |  Facebook  |  Instagram', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
                        SizedBox(height: 2),
                        Text('Thank you for choosing Bee Beyonnd.', style: TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // PRIMARY SHORT CRISP ACTION BUTTON
            ThreeDButton(
              text: _primaryButtonText,
              fontSize: 14,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              onPressed: () => _onPrimaryAction(context),
            ),

            const SizedBox(height: 12),

            // SECONDARY ACTION BUTTONS: DOWNLOAD PDF & ALL INVOICES
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
                    label: const Text(
                      'Download PDF',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
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
                    label: const Text(
                      'All Invoices',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
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

  Widget _buildMetaRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false, bool alignCenter = false, bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : (alignCenter ? TextAlign.center : TextAlign.left),
        style: TextStyle(
          fontSize: isHeader ? 9.5 : 9,
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
    );
  }

  TableRow _buildSummaryRow(String label, String value, {bool isHighlighted = false}) {
    return TableRow(
      decoration: isHighlighted ? const BoxDecoration(color: greenLightBg) : null,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? greenPrimary : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
