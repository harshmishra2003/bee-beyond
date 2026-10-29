import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/orders/domain/entities/receipt_entity.dart';
import '../theme/app_colors.dart';
import '../utils/app_alert_manager.dart';
import '../utils/currency_utils.dart';

class ReceiptPdfService {
  static final PdfColor greenPrimary = PdfColor.fromHex('#12683A');
  static final PdfColor greenLightBg = PdfColor.fromHex('#E2EFE8');
  static final PdfColor greyBgBox = PdfColor.fromHex('#F2F5F3');
  static final PdfColor borderColor = PdfColor.fromHex('#CBD5E1');

  /// Generates the raw PDF bytes matching the exact Bee Beyonnd Invoice Template
  static Future<pw.Document> generatePdfDocument(ReceiptEntity receipt) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy').format(receipt.date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. TOP BRANDING HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo Placeholder Box / Branding
                  pw.Container(
                    width: 70,
                    height: 70,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: greenLightBg,
                      border: pw.Border.all(color: greenPrimary, width: 1.5),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text('BEE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: greenPrimary, fontSize: 16)),
                  ),
                  pw.SizedBox(width: 14),

                  // Company Contact Info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'BEE BEYONND',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: greenPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Steps Towards Mental and Physical Well-Being',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Office: Dotom Isle, Jankalyan Nagar, Malad West, Mumbai - 400095',
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          'GSTIN: 27AAQPS5062E1ZD',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                        ),
                        pw.Text(
                          'Email: beebeeyonnd5@gmail.com',
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          'Contact: 8850920901 | Alternate: 9892711391 | WhatsApp: 9967326151',
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Container(height: 2, color: greenPrimary),
              pw.SizedBox(height: 12),

              // 2. INVOICE TITLE & META GRID
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 6),

              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: greyBgBox,
                  border: pw.Border.all(color: borderColor, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildKeyValueRow('Invoice No.', receipt.receiptId),
                          pw.SizedBox(height: 4),
                          _buildKeyValueRow('Due Date', dateStr),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildKeyValueRow('Invoice Date', dateStr),
                          pw.SizedBox(height: 4),
                          _buildKeyValueRow('Place of Supply', 'Maharashtra (27)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // 3. BILL TO & CUSTOMER DETAILS GRID
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  children: [
                    // Header Row
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      color: greyBgBox,
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text('BILL TO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: greenPrimary)),
                          ),
                          pw.Expanded(
                            child: pw.Text('Customer Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: greenPrimary)),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(height: 1, color: borderColor),

                    // Body Row
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Customer / Company Name:', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                                pw.Text(receipt.customerName, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 6),
                                pw.Text('Billing Address:', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                                pw.Text(receipt.deliveryAddress, style: const pw.TextStyle(fontSize: 9, color: PdfColors.black)),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildKeyValueRow('Phone:', receipt.customerPhone),
                                pw.SizedBox(height: 4),
                                _buildKeyValueRow('Email:', receipt.customerEmail),
                                pw.SizedBox(height: 4),
                                _buildKeyValueRow('GSTIN (if applicable):', 'URP (Unregistered)'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // 4. ITEMS TABLE
              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 0.8),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(40),
                  3: const pw.FlexColumnWidth(1.2),
                  4: const pw.FlexColumnWidth(1.2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: greenPrimary),
                    children: [
                      _buildTableHeaderCell('Sr.'),
                      _buildTableHeaderCell('Description / Service'),
                      _buildTableHeaderCell('Qty', alignCenter: true),
                      _buildTableHeaderCell('Rate (INR)', alignRight: true),
                      _buildTableHeaderCell('Amount (INR)', alignRight: true),
                    ],
                  ),

                  // Dynamic Table Rows
                  ...List.generate(receipt.items.length < 5 ? 5 : receipt.items.length, (index) {
                    if (index < receipt.items.length) {
                      final item = receipt.items[index];
                      return pw.TableRow(
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell(item.name, isBold: true),
                          _buildTableCell('${item.quantity}', alignCenter: true),
                          _buildTableCell(CurrencyUtils.formatINR(item.unitPrice), alignRight: true),
                          _buildTableCell(CurrencyUtils.formatINR(item.totalPrice), alignRight: true, isBold: true),
                        ],
                      );
                    } else {
                      // Padding Empty Rows to match exact template proportions
                      return pw.TableRow(
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

              pw.SizedBox(height: 12),

              // 5. NOTES & SUMMARY CALCULATION
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Notes Box
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Notes / Payment Terms', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5, color: PdfColors.black)),
                        pw.SizedBox(height: 4),
                        pw.Text('Paid via ${receipt.paymentMethod} • Ref #${receipt.orderId}', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                        pw.SizedBox(height: 2),
                        pw.Text('Official digital receipt issued by Bee Beyonnd.', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text('Thank you for choosing Bee Beyonnd.', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: greenPrimary)),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 14),

                  // Right Calculation Table
                  pw.Expanded(
                    flex: 4,
                    child: pw.Table(
                      border: pw.TableBorder.all(color: borderColor, width: 0.8),
                      children: [
                        _buildSummaryTableRow('Subtotal', CurrencyUtils.formatINR(receipt.subtotal)),
                        if (receipt.discount > 0)
                          _buildSummaryTableRow('Discount (if any)', '-${CurrencyUtils.formatINR(receipt.discount)}'),
                        _buildSummaryTableRow('Tax / GST (18%)', CurrencyUtils.formatINR(receipt.totalGst)),
                        _buildSummaryTableRow('GRAND TOTAL', CurrencyUtils.formatINR(receipt.grandTotal), isHighlighted: true),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              // 6. PAYMENT DETAILS & SIGNATURE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Payment Details UPI / Bank Transfer:', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text('beebeeyond@okaxis / HDFC Bank', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Authorised Signature:', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text('Bee Beyonnd (Digitally Signed)', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(height: 1, color: borderColor),
              pw.SizedBox(height: 8),

              // 7. FOOTER SOCIAL LINKS & THANK YOU
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Connect with Bee Beyonnd', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: greenPrimary)),
                    pw.SizedBox(height: 2),
                    pw.Text('LinkedIn  |  Facebook  |  Instagram', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    pw.SizedBox(height: 2),
                    pw.Text('Thank you for choosing Bee Beyonnd.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Row _buildKeyValueRow(String key, String value) {
    return pw.Row(
      children: [
        pw.Text('$key ', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
        pw.Expanded(
          child: pw.Text(value, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String text, {bool alignCenter = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : (alignCenter ? pw.TextAlign.center : pw.TextAlign.left),
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isBold = false, bool alignCenter = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : (alignCenter ? pw.TextAlign.center : pw.TextAlign.left),
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.TableRow _buildSummaryTableRow(String label, String value, {bool isHighlighted = false}) {
    return pw.TableRow(
      decoration: isHighlighted ? pw.BoxDecoration(color: greenLightBg) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.black,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: isHighlighted ? greenPrimary : PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  /// Download/Save PDF locally to device storage & open preview
  static Future<void> downloadAndSaveReceiptPdf(BuildContext context, ReceiptEntity receipt) async {
    try {
      final pdfDoc = await generatePdfDocument(receipt);
      final pdfBytes = await pdfDoc.save();

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${receipt.receiptId}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        AppAlertManager.showFloatingToast(
          context,
          title: 'Tax Invoice Saved',
          message: 'Saved official PDF (${receipt.receiptId}.pdf) to local downloads',
          icon: Icons.task_alt_rounded,
          backgroundColor: const Color(0xFF0F172A),
          accentColor: const Color(0xFF10B981),
          actionLabel: 'PRINT / VIEW',
          onAction: () {
            Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async => pdfBytes,
              name: '${receipt.receiptId}.pdf',
            );
          },
        );
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: '${receipt.receiptId}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        AppAlertManager.showFloatingToast(
          context,
          title: 'Download Failed',
          message: 'Could not save receipt PDF: $e',
          icon: Icons.error_outline_rounded,
          backgroundColor: const Color(0xFF0F172A),
          accentColor: const Color(0xFFEF4444),
          actionLabel: 'RETRY',
          onAction: () => downloadAndSaveReceiptPdf(context, receipt),
        );
      }
    }
  }

  /// Share real PDF file via Native Share Sheet
  static Future<void> shareReceipt(BuildContext context, ReceiptEntity receipt) async {
    try {
      final pdfDoc = await generatePdfDocument(receipt);
      final pdfBytes = await pdfDoc.save();

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${receipt.receiptId}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      final xFile = XFile(filePath);

      await SharePlus.instance.share(
        ShareParams(
          text: 'Official Tax Invoice (${receipt.receiptId}) from Bee Beyonnd for ${receipt.title}.\nTotal Paid: ${CurrencyUtils.formatINR(receipt.grandTotal)}',
          subject: 'Bee Beyonnd Official Receipt - ${receipt.receiptId}',
          files: [xFile],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing receipt: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
