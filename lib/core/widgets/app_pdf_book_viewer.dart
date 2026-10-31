import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/books/presentation/providers/books_provider.dart';
import '../../features/checkout/presentation/providers/payment_provider.dart';
import '../services/razorpay_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_alert_manager.dart';
import '../utils/currency_utils.dart';

class PdfUrlResolver {
  static const String fallbackPdfUrl =
      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

  static String resolveUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return fallbackPdfUrl;
    String url = rawUrl.trim();

    if (url.contains('drive.google.com')) {
      final regExp = RegExp(r'/(?:file/d/|id=)([\w-]+)');
      final match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1);
        return 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }

    if (url.contains('dropbox.com') && url.contains('dl=0')) {
      return url.replaceAll('dl=0', 'dl=1');
    }

    if (url.contains('docs.google.com/document/d/')) {
      final regExp = RegExp(r'/document/d/([\w-]+)');
      final match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final docId = match.group(1);
        return 'https://docs.google.com/document/d/$docId/export?format=pdf';
      }
    }

    if (url.contains('/admin/uploads/')) {
      url = url.replaceAll('/admin/uploads/', '/uploads/');
    } else if (url.contains('admin/uploads/')) {
      url = url.replaceAll('admin/uploads/', 'uploads/');
    } else if (url.contains('/admin/') && (url.endsWith('.pdf') || url.contains('.pdf?'))) {
      url = url.replaceAll('/admin/', '/');
    } else if (url.startsWith('admin/') && (url.endsWith('.pdf') || url.contains('.pdf?'))) {
      url = url.substring(6);
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/api/')) {
      return 'https://metricstestingapp.xyz$url';
    }
    if (url.startsWith('/uploads/')) {
      return 'https://metricstestingapp.xyz$url';
    }
    if (url.startsWith('uploads/')) {
      return 'https://metricstestingapp.xyz/$url';
    }
    if (url.startsWith('/')) {
      return 'https://metricstestingapp.xyz/api$url';
    }
    if (url.startsWith('api/')) {
      return 'https://metricstestingapp.xyz/$url';
    }
    return 'https://metricstestingapp.xyz/api/$url';
  }

  static bool isValidPdfBytes(Uint8List bytes) {
    if (bytes.length < 5) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }
}

class AppPdfBookViewer extends ConsumerStatefulWidget {
  final String title;
  final String pdfUrl;
  final String? subtitle;
  final String? description;
  final int totalPages;
  final bool isSampleMode;
  final double price;
  final String bookId;

  const AppPdfBookViewer({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.subtitle,
    this.description,
    this.totalPages = 120,
    this.isSampleMode = false,
    this.price = 0.0,
    this.bookId = '',
  });

  static void show(
    BuildContext context, {
    required String title,
    required String pdfUrl,
    String? subtitle,
    String? description,
    int totalPages = 120,
    bool isSampleMode = false,
    double price = 0.0,
    String bookId = '',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.96,
        minChildSize: 0.6,
        maxChildSize: 0.98,
        expand: false,
        builder: (sheetContext, scrollController) => AppPdfBookViewer(
          title: title,
          pdfUrl: pdfUrl,
          subtitle: subtitle,
          description: description,
          totalPages: totalPages,
          isSampleMode: isSampleMode,
          price: price,
          bookId: bookId,
        ),
      ),
    );
  }

  @override
  ConsumerState<AppPdfBookViewer> createState() => _AppPdfBookViewerState();
}

class _AppPdfBookViewerState extends ConsumerState<AppPdfBookViewer> {
  late final PdfViewerController _pdfViewerController;
  RazorpayService? _razorpayService;

  String? _localFilePath;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isShowingSampleDialog = false;

  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> _totalPagesNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _razorpayService = RazorpayService();
    _setupRazorpayListeners();
    _loadPdfDocument(widget.pdfUrl);
  }

  void _setupRazorpayListeners() {
    _razorpayService?.onSuccess = (response) async {
      if (!mounted) return;
      if (widget.bookId.isNotEmpty) {
        ref.read(purchasedBooksProvider.notifier).markPurchased(widget.bookId);
      }
      Navigator.pop(context);
      AppAlertManager.showFloatingToast(
        context,
        title: 'Full E-Book Unlocked! 🎉',
        message: 'Thank you! You now have full access to "${widget.title}".',
        icon: Icons.check_circle_rounded,
      );

      AppPdfBookViewer.show(
        context,
        title: widget.title,
        pdfUrl: widget.pdfUrl,
        subtitle: widget.subtitle,
        description: widget.description,
        totalPages: widget.totalPages,
        isSampleMode: false,
      );
    };

    _razorpayService?.onError = (response) {
      if (!mounted) return;
      AppAlertManager.showFloatingToast(
        context,
        title: 'Payment Cancelled / Declined',
        message: response.message ?? 'Transaction was cancelled.',
        icon: Icons.info_outline_rounded,
      );
    };
  }

  @override
  void dispose() {
    _currentPageNotifier.dispose();
    _totalPagesNotifier.dispose();
    _pdfViewerController.dispose();
    _razorpayService?.dispose();
    super.dispose();
  }

  Future<void> _loadPdfDocument(String rawUrl) async {
    final logger = Logger();

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final targetUrl = PdfUrlResolver.resolveUrl(rawUrl);

    try {
      final token = await SecureStorageService().getAuthToken();
      final headers = <String, String>{
        'User-Agent': 'BeeBeeyond/1.0.0 (Android)',
        'Accept': 'application/pdf,application/octet-stream,*/*',
      };

      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.trim()}';
      }

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.bytes,
        validateStatus: (status) => true,
        headers: headers,
      ));

      final response = await dio.get<List<int>>(targetUrl);
      final statusCode = response.statusCode ?? 0;

      if (statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        final isValidPdf = PdfUrlResolver.isValidPdfBytes(bytes);

        if (isValidPdf) {
          final tempDir = await getTemporaryDirectory();
          final fileName = 'book_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(bytes);

          if (mounted) {
            setState(() {
              _localFilePath = file.path;
              _isLoading = false;
            });
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load PDF document (HTTP $statusCode). Please check your connection.';
        });
      }
    } catch (e) {
      logger.e('[PDF_VIEWER_ERROR] Network Exception: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not connect to PDF server. Please check your internet connection.';
        });
      }
    }
  }

  int _calculateSampleLimit(int total) {
    if (total <= 0) total = widget.totalPages;
    final calculated = (total * 0.10).round();
    return calculated.clamp(3, 12);
  }

  void _showSampleLimitReachedDialog(int sampleLimit) {
    if (_isShowingSampleDialog) return;
    _isShowingSampleDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.bookmark_remove_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Sample Limit Reached',
              style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have reached the end of the free sample ($sampleLimit pages) for "${widget.title}".',
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Full E-Book Price:',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    CurrencyUtils.formatINR(widget.price),
                    style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isShowingSampleDialog = false;
              Navigator.pop(ctx);
            },
            child: Text('Dismiss', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _isShowingSampleDialog = false;
              Navigator.pop(ctx);
              _triggerPurchase();
            },
            icon: const Icon(Icons.bolt_rounded, size: 16),
            label: Text('BUY FULL E-BOOK', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerPurchase() async {
    final currentUser = ref.read(authStateProvider).user;
    final customerName = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'Bee Beyonnd Student';
    final customerPhone = currentUser?.phone.isNotEmpty == true ? currentUser!.phone : '9876543210';
    final customerEmail = currentUser?.email.isNotEmpty == true ? currentUser!.email : 'student@beebeyonnd.com';

    final receiptId = 'REC-BOOK-${DateTime.now().millisecondsSinceEpoch}';

    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final serverOrder = await paymentRepo.createServerOrder(
        amount: widget.price,
        currency: 'INR',
        receiptId: receiptId,
        items: [
          {
            'product_id': widget.bookId,
            'quantity': 1,
          }
        ],
      );

      _razorpayService?.openCheckout(
        keyId: serverOrder.keyId.isNotEmpty ? serverOrder.keyId : 'rzp_test_5S2JgG4M8K3n9x',
        amountPaise: serverOrder.amountPaise > 0 ? serverOrder.amountPaise : (widget.price * 100).toInt(),
        gatewayOrderId: serverOrder.gatewayOrderId,
        name: 'Bee Beyonnd',
        description: 'Digital E-Book Purchase - ${widget.title}',
        contact: customerPhone,
        email: customerEmail,
        customerName: customerName,
      );
    } catch (_) {
      // Fallback checkout mode
      _razorpayService?.openCheckout(
        keyId: 'rzp_test_5S2JgG4M8K3n9x',
        amountPaise: (widget.price * 100).toInt(),
        gatewayOrderId: '',
        name: 'Bee Beyonnd',
        description: 'Digital E-Book Purchase - ${widget.title}',
        contact: customerPhone,
        email: customerEmail,
        customerName: customerName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // HEADER CONTROL BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isSampleMode ? const Color(0xFFFFFBEB) : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isSampleMode ? Icons.bookmark_border_rounded : Icons.menu_book_rounded,
                      color: widget.isSampleMode ? Colors.amber.shade800 : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.isSampleMode
                              ? 'Free Sample Preview Mode'
                              : (widget.subtitle ?? 'Official E-Book Reader'),
                          style: GoogleFonts.poppins(
                            color: widget.isSampleMode ? Colors.amber.shade800 : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.borderSubtle),

            // MAIN PDF READER CANVAS
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : (_localFilePath != null
                      ? _buildPdfCanvas()
                      : _buildErrorState()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            widget.isSampleMode ? 'Opening Free Sample Preview...' : 'Opening E-Book Reader...',
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCanvas() {
    return RepaintBoundary(
      child: Stack(
        children: [
          // HORIZONTAL E-READER MODE
          SfPdfViewer.file(
            File(_localFilePath!),
            controller: _pdfViewerController,
            scrollDirection: PdfScrollDirection.horizontal,
            pageLayoutMode: PdfPageLayoutMode.single,
            canShowScrollHead: false,
            canShowScrollStatus: false,
            enableDoubleTapZooming: true,
            enableTextSelection: true,
            pageSpacing: 0,
            onPageChanged: (PdfPageChangedDetails details) {
              final total = _totalPagesNotifier.value;
              final sampleLimit = _calculateSampleLimit(total);

              if (widget.isSampleMode && details.newPageNumber > sampleLimit) {
                _pdfViewerController.jumpToPage(sampleLimit);
                _showSampleLimitReachedDialog(sampleLimit);
                return;
              }
              _currentPageNotifier.value = details.newPageNumber;
            },
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              if (mounted) {
                _totalPagesNotifier.value = details.document.pages.count;
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),

          // BOTTOM PROGRESS BAR
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: _totalPagesNotifier,
              builder: (context, totalPages, child) {
                if (totalPages <= 0) return const SizedBox.shrink();
                return ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, child) {
                    final sampleLimit = _calculateSampleLimit(totalPages);
                    final percent = ((currentPage / totalPages) * 100).toInt();

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.isSampleMode
                                ? '${sampleLimit - currentPage} pages left in sample'
                                : 'Page $currentPage of $totalPages',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: GoogleFonts.poppins(
                              color: Colors.amberAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'PDF document could not be rendered.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadPdfDocument(widget.pdfUrl),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry Loading PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
