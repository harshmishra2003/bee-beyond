import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../routing/route_paths.dart';
import '../services/secure_storage_service.dart';
import '../theme/app_colors.dart';

class PdfUrlResolver {
  static const String fallbackPdfUrl =
      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

  static String resolveUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return fallbackPdfUrl;
    String url = rawUrl.trim();

    // 1. Convert Google Drive file URLs
    if (url.contains('drive.google.com')) {
      final regExp = RegExp(r'/(?:file/d/|id=)([\w-]+)');
      final match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1);
        return 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }

    // 2. Convert Dropbox links
    if (url.contains('dropbox.com') && url.contains('dl=0')) {
      return url.replaceAll('dl=0', 'dl=1');
    }

    // 3. Convert Google Docs URLs
    if (url.contains('docs.google.com/document/d/')) {
      final regExp = RegExp(r'/document/d/([\w-]+)');
      final match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final docId = match.group(1);
        return 'https://docs.google.com/document/d/$docId/export?format=pdf';
      }
    }

    // 4. Strip /admin/ path prefixes for uploaded static assets
    // Admin uploads are stored in public /uploads/ directory on backend,
    // but DB paths often contain /admin/uploads/ which redirects to Admin Login HTML.
    if (url.contains('/admin/uploads/')) {
      url = url.replaceAll('/admin/uploads/', '/uploads/');
    } else if (url.contains('admin/uploads/')) {
      url = url.replaceAll('admin/uploads/', 'uploads/');
    } else if (url.contains('/admin/') && (url.endsWith('.pdf') || url.contains('.pdf?'))) {
      url = url.replaceAll('/admin/', '/');
    } else if (url.startsWith('admin/') && (url.endsWith('.pdf') || url.contains('.pdf?'))) {
      url = url.substring(6);
    }

    // 5. Absolute HTTP / HTTPS
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 6. Relative paths
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
    // Magic header check: %PDF-
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }
}

class AppPdfBookViewer extends StatefulWidget {
  final String title;
  final String pdfUrl;
  final String? subtitle;
  final String? description;
  final List<String>? samplePagesContent;
  final bool isPreviewMode;

  const AppPdfBookViewer({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.subtitle,
    this.description,
    this.samplePagesContent,
    this.isPreviewMode = false,
  });

  /// Static helper method to show the viewer in a modal bottom sheet
  static void show(
    BuildContext context, {
    required String title,
    required String pdfUrl,
    String? subtitle,
    String? description,
    List<String>? samplePagesContent,
    bool isPreviewMode = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppPdfBookViewer(
        title: title,
        pdfUrl: pdfUrl,
        subtitle: subtitle,
        description: description,
        samplePagesContent: samplePagesContent,
        isPreviewMode: isPreviewMode,
      ),
    );
  }

  @override
  State<AppPdfBookViewer> createState() => _AppPdfBookViewerState();
}

class _AppPdfBookViewerState extends State<AppPdfBookViewer> {
  late final PdfViewerController _pdfViewerController;
  String? _localFilePath;
  bool _isLoading = true;
  String? _errorMessage;
  int? _accessErrorCode; // 401 or 403

  // ValueNotifiers to isolate UI rebuilds during high-speed scrolling
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> _totalPagesNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPdfDocument(widget.pdfUrl);
  }

  @override
  void dispose() {
    _currentPageNotifier.dispose();
    _totalPagesNotifier.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfDocument(String rawUrl) async {
    final logger = Logger();

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _accessErrorCode = null;
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

      logger.i(
        '[PDF_VIEWER_NETWORK_LOG] Opening PDF:\n'
        '  Raw URL: $rawUrl\n'
        '  Target URL: $targetUrl\n'
        '  Auth Token Present: ${token != null && token.trim().isNotEmpty}'
      );

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

          logger.i('[PDF_VIEWER_SUCCESS] PDF saved to local temp storage: ${file.path}');

          if (mounted) {
            setState(() {
              _localFilePath = file.path;
              _isLoading = false;
            });
          }
          return;
        } else {
          // Status 200 returned non-PDF content (e.g. Admin login HTML page or backend error)
          final decodedBody = utf8.decode(bytes, allowMalformed: true);
          logger.e('[PDF_VIEWER_ERROR] HTTP 200 returned NON-PDF content: ${decodedBody.substring(0, decodedBody.length > 200 ? 200 : decodedBody.length)}');

          // Attempt fallback load if targetUrl was customized
          String? retryUrl;
          if (targetUrl.contains('admin')) {
            retryUrl = targetUrl.replaceAll('/admin/', '/').replaceAll('admin/', '');
          } else if (targetUrl != PdfUrlResolver.fallbackPdfUrl) {
            retryUrl = PdfUrlResolver.fallbackPdfUrl;
          }

          if (retryUrl != null && retryUrl != targetUrl) {
            logger.w('[PDF_VIEWER_RETRY] Attempting fallback PDF load: $retryUrl');
            try {
              final retryResp = await dio.get<List<int>>(retryUrl);
              if (retryResp.statusCode == 200 && retryResp.data != null) {
                final retryBytes = Uint8List.fromList(retryResp.data!);
                if (PdfUrlResolver.isValidPdfBytes(retryBytes)) {
                  final tempDir = await getTemporaryDirectory();
                  final fileName = 'book_pdf_fallback_${DateTime.now().millisecondsSinceEpoch}.pdf';
                  final file = File('${tempDir.path}/$fileName');
                  await file.writeAsBytes(retryBytes);

                  if (mounted) {
                    setState(() {
                      _localFilePath = file.path;
                      _isLoading = false;
                    });
                  }
                  return;
                }
              }
            } catch (e) {
              logger.e('[PDF_VIEWER_RETRY_ERROR] Fallback PDF load failed: $e');
            }
          }

          final isHtmlContent = decodedBody.trim().startsWith('<') || decodedBody.contains('Login');
          final cleanError = isHtmlContent
              ? 'The requested study PDF file link is restricted or unaccessible on the backend server. Please check your account permissions or try again later.'
              : decodedBody;

          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = cleanError;
            });
          }
          return;
        }
      }

      if (statusCode == 401) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _accessErrorCode = 401;
            _errorMessage = 'Authentication required. Please log in again to access this study PDF.';
          });
        }
        return;
      }

      if (statusCode == 403) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _accessErrorCode = 403;
            _errorMessage = 'VIP Membership Required 👑\nThis lesson PDF is exclusive to paid members. Upgrade your plan to unlock instant reading access.';
          });
        }
        return;
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
          _errorMessage = 'Could not connect to the PDF server. Please check your internet connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.94,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Color(0xFFEF4444),
                      size: 22,
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
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          widget.subtitle ?? 'Official Study Handbook & PDF Reader',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
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
                      : _buildErrorOrEmptyState()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFEF4444)),
          SizedBox(height: 16),
          Text(
            'Opening Study PDF Reader...',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Loading PDF document pages',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
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
          // HIGH-PERFORMANCE DIRECT PDF READER
          SfPdfViewer.file(
            File(_localFilePath!),
            controller: _pdfViewerController,
            canShowScrollHead: false,
            canShowScrollStatus: false,
            enableDoubleTapZooming: true,
            enableTextSelection: true,
            pageSpacing: 4,
            onPageChanged: (PdfPageChangedDetails details) {
              if (widget.isPreviewMode && details.newPageNumber > 2) {
                _pdfViewerController.jumpToPage(2);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preview limit reached (Max 2 pages). Please purchase the book to unlock full reading access.'),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
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
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Could not render PDF document: ${details.description}';
                });
              }
            },
          ),

          // FLOATING PAGE BADGE OVERLAY
          Positioned(
            top: 12,
            right: 14,
            child: ValueListenableBuilder<int>(
              valueListenable: _totalPagesNotifier,
              builder: (context, totalPages, child) {
                if (totalPages <= 0) return const SizedBox.shrink();
                return ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, child) {
                    final percent = ((currentPage / totalPages) * 100).toInt();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24, width: 0.8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))
                        ],
                      ),
                      child: Text(
                        '$currentPage / $totalPages ($percent%)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildErrorOrEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _accessErrorCode == 403
                    ? const Color(0xFFFDF4FF)
                    : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _accessErrorCode == 403
                    ? Icons.stars_rounded
                    : (_accessErrorCode == 401 ? Icons.lock_outline_rounded : Icons.picture_as_pdf_rounded),
                color: _accessErrorCode == 403
                    ? const Color(0xFF6E4F9A)
                    : const Color(0xFFEF4444),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'PDF document could not be rendered automatically.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 20),

            if (_accessErrorCode == 403)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E4F9A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.membership);
                },
                icon: const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 18),
                label: const Text(
                  'EXPLORE VIP MEMBERSHIP',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              )
            else if (_accessErrorCode == 401)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.login);
                },
                icon: const Icon(Icons.login_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'LOG IN AGAIN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  _loadPdfDocument(widget.pdfUrl);
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Retry Loading PDF',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
