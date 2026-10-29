import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    // 4. Absolute HTTP / HTTPS
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 5. Relative paths
    if (url.startsWith('/api/')) {
      return 'https://metricstestingapp.xyz$url';
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

  const AppPdfBookViewer({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.subtitle,
    this.description,
    this.samplePagesContent,
  });

  /// Static helper method to show the viewer in a modal bottom sheet
  static void show(
    BuildContext context, {
    required String title,
    required String pdfUrl,
    String? subtitle,
    String? description,
    List<String>? samplePagesContent,
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
      ),
    );
  }

  @override
  State<AppPdfBookViewer> createState() => _AppPdfBookViewerState();
}

class _AppPdfBookViewerState extends State<AppPdfBookViewer> {
  late PdfViewerController _pdfViewerController;
  String? _localFilePath;
  bool _isLoading = true;
  String? _errorMessage;
  int? _accessErrorCode; // 401 or 403
  int _totalPages = 0;
  int _currentPage = 1;
  bool _showTextTab = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPdfDocument(widget.pdfUrl);
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfDocument(String rawUrl) async {
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

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.bytes,
        validateStatus: (status) => true,
        headers: headers,
      ));

      final response = await dio.get<List<int>>(targetUrl);

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);

        if (PdfUrlResolver.isValidPdfBytes(bytes)) {
          final tempDir = await getTemporaryDirectory();
          final fileName = 'lesson_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(bytes);

          if (mounted) {
            setState(() {
              _localFilePath = file.path;
              _isLoading = false;
            });
          }
          return;
        } else {
          // Status 200 but bytes are not %PDF- (e.g. JSON error object)
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'The server response could not be verified as a valid PDF document.';
            });
          }
          return;
        }
      }

      if (response.statusCode == 401) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _accessErrorCode = 401;
            _errorMessage = 'Authentication required. Please log in again to access this study PDF.';
          });
        }
        return;
      }

      if (response.statusCode == 403) {
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
          _errorMessage = 'Could not load PDF document (HTTP ${response.statusCode}). Please check your connection.';
        });
      }
    } catch (e) {
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
    final hasTextContent = (widget.description != null && widget.description!.isNotEmpty) ||
        (widget.samplePagesContent != null && widget.samplePagesContent!.isNotEmpty);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
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

          // HEADER BAR
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
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
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.subtitle ?? 'Official Study Book & Module PDF',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
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

          // TOGGLE TABS
          if (hasTextContent)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showTextTab = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: !_showTextTab ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: !_showTextTab
                              ? const [
                                  BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 14,
                              color: !_showTextTab ? const Color(0xFFEF4444) : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PDF Document',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_showTextTab ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showTextTab = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: _showTextTab ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _showTextTab
                              ? const [
                                  BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 14,
                              color: _showTextTab ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Text / Reading Notes',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _showTextTab ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1, color: AppColors.borderSubtle),

          // CONTENT VIEW BODY
          Expanded(
            child: _showTextTab
                ? _buildTextContentBody()
                : (_isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFFEF4444)),
                            SizedBox(height: 16),
                            Text(
                              'Fetching Protected Study PDF...',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Verifying authorization & streaming document',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : (_localFilePath != null
                        ? Stack(
                            children: [
                              SfPdfViewer.file(
                                File(_localFilePath!),
                                controller: _pdfViewerController,
                                canShowScrollHead: true,
                                canShowScrollStatus: true,
                                enableDoubleTapZooming: true,
                                enableTextSelection: true,
                                pageSpacing: 8,
                                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                                  if (mounted) {
                                    setState(() {
                                      _totalPages = details.document.pages.count;
                                      _isLoading = false;
                                    });
                                  }
                                },
                                onPageChanged: (PdfPageChangedDetails details) {
                                  if (mounted) {
                                    setState(() {
                                      _currentPage = details.newPageNumber;
                                    });
                                  }
                                },
                                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                      _errorMessage =
                                          'Could not render PDF document: ${details.description}';
                                    });
                                  }
                                },
                              ),

                              // PAGE NUMBER BADGE OVERLAY
                              if (_totalPages > 0)
                                Positioned(
                                  bottom: 14,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xDD0F172A),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white30, width: 0.8),
                                      boxShadow: const [
                                        BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))
                                      ],
                                    ),
                                    child: Text(
                                      'Page $_currentPage of $_totalPages',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : _buildErrorOrEmptyState())),
          ),

          // FOOTER CONTROLS ROW
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _loadPdfDocument(widget.pdfUrl);
                },
                icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                label: const Text(
                  'Reload PDF Document',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContentBody() {
    final description = widget.description ?? '';
    final pages = widget.samplePagesContent ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (description.isNotEmpty) ...[
          const Text(
            'Book Overview & Summary',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
          ),
          const SizedBox(height: 20),
        ],

        if (pages.isNotEmpty) ...[
          const Text(
            'Chapter Reading Notes & Study Content',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          ...pages.asMap().entries.map((entry) {
            final idx = entry.key;
            final pageText = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Section ${idx + 1}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pageText,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.45),
                  ),
                ],
              ),
            );
          }),
        ],

        if (description.isEmpty && pages.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No text reading notes provided for this book.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),
      ],
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
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
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
