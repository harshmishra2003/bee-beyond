import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/page_transitions.dart';
import '../../domain/entities/book_item.dart';
import '../providers/library_provider.dart';

class MaterialScreen extends ConsumerStatefulWidget {
  const MaterialScreen({super.key});

  @override
  ConsumerState<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends ConsumerState<MaterialScreen> {
  String _selectedCategory = 'All';
  final Set<String> _bookmarkedIds = {};

  void _openBookViewer(BookItem book) {
    Navigator.of(context).push(
      buildSmoothPageRoute(
        page: _BookPdfReaderScreen(book: book),
        type: AppTransitionType.slideUp,
      ),
    );
  }

  void _toggleBookmark(String bookId) {
    setState(() {
      if (_bookmarkedIds.contains(bookId)) {
        _bookmarkedIds.remove(bookId);
      } else {
        _bookmarkedIds.add(bookId);
      }
    });
  }

  List<String> _extractCategories(List<BookItem> books) {
    final Set<String> cats = {'All'};
    for (var b in books) {
      if (b.category.isNotEmpty) cats.add(b.category);
    }
    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksAndMaterialsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Books & Study Materials'),
      body: booksAsync.when(
        data: (allBooks) {
          if (allBooks.isEmpty) {
            return _buildEmptyState();
          }

          final categories = _extractCategories(allBooks);
          final filteredBooks = allBooks.where((b) {
            if (_selectedCategory == 'All') return true;
            return b.category.toLowerCase() == _selectedCategory.toLowerCase();
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 12),

              // CATEGORY FILTER CHIPS
              if (categories.length > 1)
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategory == cat;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(60),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // LIST HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedCategory Books (${filteredBooks.length})',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.library_books_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // DYNAMIC BOOKS LIST
              Expanded(
                child: filteredBooks.isEmpty
                    ? Center(
                        child: Text(
                          'No books found in $_selectedCategory category.',
                          style: const TextStyle(color: AppColors.textHint, fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredBooks.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          final isBookmarked = _bookmarkedIds.contains(book.id);

                          return _buildBookCard(book, isBookmarked);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Error loading books: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(booksAndMaterialsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Study Materials Available Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our publishing team is uploading certified digital handbooks, study materials, and reference charts. Check back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOOK CARD BUILDER
  Widget _buildBookCard(BookItem book, bool isBookmarked) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C4B489B),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openBookViewer(book),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover Box
                Container(
                  width: 70,
                  height: 95,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        book.categoryColor,
                        book.categoryColor.withAlpha(200),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 3)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        '${book.totalPages} Pgs',
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: book.categoryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              book.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: isBookmarked ? AppColors.primary : AppColors.textHint,
                              size: 20,
                            ),
                            onPressed: () => _toggleBookmark(book.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${book.author} • ${book.size}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 10),

                      // READ BOOK BUTTON
                      SizedBox(
                        height: 36,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            elevation: 0,
                          ),
                          onPressed: () => _openBookViewer(book),
                          icon: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 16),
                          label: const Text(
                            'READ BOOK',
                            style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// IN-APP DYNAMIC PDF BOOK READER SCREEN
class _BookPdfReaderScreen extends StatefulWidget {
  final BookItem book;

  const _BookPdfReaderScreen({required this.book});

  @override
  State<_BookPdfReaderScreen> createState() => _BookPdfReaderScreenState();
}

class _BookPdfReaderScreenState extends State<_BookPdfReaderScreen> {
  static const String _fallbackPdfUrl =
      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

  Uint8List? _pdfBytes;
  bool _isLoadingPdf = true;
  String? _errorMessage;
  bool _isUsingFallback = false;

  @override
  void initState() {
    super.initState();
    _downloadPdfBytes(widget.book.pdfUrl);
  }

  Future<void> _downloadPdfBytes(String rawUrl) async {
    final url = rawUrl.trim();
    final targetUrl = (url.isNotEmpty && url.startsWith('http'))
        ? url
        : _fallbackPdfUrl;

    if (targetUrl == _fallbackPdfUrl) {
      _isUsingFallback = true;
    }

    if (mounted) {
      setState(() {
        _isLoadingPdf = true;
        _errorMessage = null;
      });
    }

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.bytes,
      ));

      final response = await dio.get<List<int>>(targetUrl);
      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        if (bytes.length >= 100) {
          if (mounted) {
            setState(() {
              _pdfBytes = bytes;
              _isLoadingPdf = false;
            });
          }
          return;
        }
      }

      if (!_isUsingFallback) {
        _isUsingFallback = true;
        _downloadPdfBytes(_fallbackPdfUrl);
      } else {
        if (mounted) {
          setState(() {
            _pdfBytes = null;
            _isLoadingPdf = false;
            _errorMessage = 'The file at this URL is not a valid PDF document.';
          });
        }
      }
    } catch (e) {
      if (!_isUsingFallback) {
        _isUsingFallback = true;
        _downloadPdfBytes(_fallbackPdfUrl);
      } else {
        if (mounted) {
          setState(() {
            _pdfBytes = null;
            _isLoadingPdf = false;
            _errorMessage =
                'Could not download PDF document. Please check network connection.';
          });
        }
      }
    }
  }

  Future<void> _openExternalBrowser() async {
    final url = widget.book.pdfUrl.trim().isNotEmpty
        ? widget.book.pdfUrl.trim()
        : _fallbackPdfUrl;

    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      final uri = Uri.parse(url);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${widget.book.author} • ${widget.book.category}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: AppColors.primary, size: 20),
            tooltip: 'Open in Browser',
            onPressed: _openExternalBrowser,
          ),
        ],
      ),
      body: _isLoadingPdf
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading & Rendering Book PDF...',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Downloading document into reader',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            )
          : (_pdfBytes != null
              ? PdfPreview(
                  build: (format) async => _pdfBytes!,
                  useActions: true,
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  pdfFileName: '${widget.book.title}.pdf',
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  onError: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded,
                              color: Color(0xFFEF4444), size: 48),
                          const SizedBox(height: 16),
                          Text(
                            widget.book.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Could not render PDF: $error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            onPressed: _openExternalBrowser,
                            icon: const Icon(Icons.open_in_new_rounded,
                                color: Colors.white, size: 18),
                            label: const Text(
                              'Open PDF in Browser',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF2F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded,
                              color: Color(0xFFEF4444), size: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.book.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage ?? 'Book PDF document unavailable.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.5),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          onPressed: _openExternalBrowser,
                          icon: const Icon(Icons.open_in_new_rounded,
                              color: Colors.white, size: 18),
                          label: const Text(
                            'Open PDF in Browser',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
    );
  }
}
