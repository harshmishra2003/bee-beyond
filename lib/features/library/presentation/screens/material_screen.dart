import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_pdf_book_viewer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/membership_access_guard.dart';
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

  void _openBookViewer(BookItem book) async {
    if (book.pdfUrl.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      try {
        final detailedBook =
            await ref.read(libraryRepositoryProvider).getBookDetail(book.id);
        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (mounted) {
          AppPdfBookViewer.show(
            context,
            title:
                detailedBook.title.isNotEmpty ? detailedBook.title : book.title,
            pdfUrl: detailedBook.pdfUrl.isNotEmpty
                ? detailedBook.pdfUrl
                : book.pdfUrl,
            subtitle: '${detailedBook.author} • ${detailedBook.category}',
            description: detailedBook.description.isNotEmpty
                ? detailedBook.description
                : book.description,
            samplePagesContent: detailedBook.samplePagesContent.isNotEmpty
                ? detailedBook.samplePagesContent
                : book.samplePagesContent,
          );
        }
        return;
      } catch (_) {
        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    }

    if (mounted) {
      AppPdfBookViewer.show(
        context,
        title: book.title,
        pdfUrl: book.pdfUrl,
        subtitle: '${book.author} • ${book.category}',
        description: book.description,
        samplePagesContent: book.samplePagesContent,
      );
    }
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

  String _formatAuthorName(String raw) {
    final clean = raw.replaceAll(RegExp(r'^By\s+', caseSensitive: false), '').trim();
    if (clean.isEmpty) return 'By Bee Beyonnd Vault';
    return 'By $clean';
  }

  List<String> _extractCategories(List<BookItem> books) {
    final Set<String> cats = {'All'};
    for (var b in books) {
      if (b.category.isNotEmpty) cats.add(b.category);
    }
    return cats.toList();
  }

  Map<String, List<BookItem>> _groupBooksByCategory(List<BookItem> books) {
    final Map<String, List<BookItem>> map = {};
    for (var b in books) {
      final cat = b.category.isNotEmpty ? b.category : 'General Healing';
      if (!map.containsKey(cat)) {
        map[cat] = [];
      }
      map[cat]!.add(b);
    }
    return map;
  }

  void _navigateToCategoryGrid(String categoryName, List<BookItem> categoryBooks) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookCategoryGridScreen(
          categoryName: categoryName,
          books: categoryBooks,
          bookmarkedIds: _bookmarkedIds,
          onToggleBookmark: _toggleBookmark,
          onOpenBook: _openBookViewer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksAndMaterialsProvider);

    return MembershipAccessGuard(
      featureName: 'Books & Study Handbooks',
      featureDescription: 'PDF handbooks, research notes & digital eBooks',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Books & Study Materials'),
        body: booksAsync.when(
          data: (allBooks) {
            if (allBooks.isEmpty) {
              return _buildEmptyState();
            }

            final categories = _extractCategories(allBooks);
            final categoryMap = _groupBooksByCategory(allBooks);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderSubtle,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color:
                                              AppColors.primary.withAlpha(60),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // IF A SPECIFIC CATEGORY IS FILTERED, SHOW 2x2 GRID DIRECTLY
                  if (_selectedCategory != 'All') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$_selectedCategory Books',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(categoryMap[_selectedCategory] ?? []).length} Books',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildCategoryGrid(
                      categoryMap[_selectedCategory] ?? [],
                    ),
                  ] else ...[
                    // SHOW SECTIONAL HORIZONTAL SCROLLABLE LISTS FOR ALL CATEGORIES
                    ...categoryMap.entries.map((entry) {
                      final categoryName = entry.key;
                      final books = entry.value;

                      return _buildCategorySection(
                        categoryName: categoryName,
                        books: books,
                      );
                    }),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
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
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.red, size: 48),
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
      ),
    );
  }

  // CATEGORY SECTION WITH HORIZONTAL SCROLLABLE LIST
  Widget _buildCategorySection({
    required String categoryName,
    required List<BookItem> books,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _navigateToCategoryGrid(categoryName, books),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'View All (${books.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // HORIZONTAL SCROLLABLE BOOKS LIST + SHINING VIEW MORE BUTTON AT END
        SizedBox(
          height: 215,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: books.length + 1, // Extra 1 for Shining "View More" Card
            itemBuilder: (context, index) {
              if (index < books.length) {
                final book = books[index];
                final isBookmarked = _bookmarkedIds.contains(book.id);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildHorizontalBookCard(book, isBookmarked),
                );
              } else {
                // SHINING VIEW MORE CARD AT THE END
                return _buildShiningViewMoreCard(
                  categoryName: categoryName,
                  books: books,
                );
              }
            },
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  // HORIZONTAL BOOK CARD (WITH FULL-FIT COVER & BEE BEYONND EMBLEM BADGE)
  Widget _buildHorizontalBookCard(BookItem book, bool isBookmarked) {
    return Container(
      width: 126,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: book.categoryColor.withAlpha(60),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E4B489B),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openBookViewer(book),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // BOOK THUMBNAIL COVER FRAME (Fills Container Completely)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
                child: SizedBox(
                  height: 132,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // THUMBNAIL IMAGE (Cover Fit)
                      book.pdfUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: book.pdfUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorWidget: (context, url, error) =>
                                  _buildDefaultBookCover(book),
                              placeholder: (context, url) =>
                                  _buildDefaultBookCover(book),
                            )
                          : _buildDefaultBookCover(book),

                      // OVERLAID BEE BEYONND EMBLEM BADGE (Top-Left)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          width: 25,
                          height: 25,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.amberAccent,
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AssetPaths.beeBeyondEmblem,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.spa_rounded,
                                      size: 14, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),

                      // OVERLAID BOOKMARK BUTTON (Top-Right)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => _toggleBookmark(book.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isBookmarked
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              size: 15,
                            ),
                          ),
                        ),
                      ),

                      // OVERLAID PDF PAGES BADGE (Bottom-Right)
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(180),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${book.totalPages} Pgs',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // BOOK TITLE & AUTHOR DETAILS (Neat, Compact & Cozy)
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 5, 7, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatAuthorName(book.author),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SHINING "VIEW MORE" CARD AT END OF HORIZONTAL ROW
  Widget _buildShiningViewMoreCard({
    required String categoryName,
    required List<BookItem> books,
  }) {
    return Container(
      width: 115,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F0C20),
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amberAccent.withAlpha(140), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30312E81),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigateToCategoryGrid(categoryName, books),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withAlpha(100),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF1E1B4B),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'VIEW MORE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore All\n$categoryName',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9.0,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DEFAULT BOOK COVER FALLBACK
  Widget _buildDefaultBookCover(BookItem book) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            book.categoryColor,
            book.categoryColor.withAlpha(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 36),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2x2 CATEGORY GRID VIEW
  Widget _buildCategoryGrid(List<BookItem> books) {
    if (books.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No books available in this category.'),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isBookmarked = _bookmarkedIds.contains(book.id);
        return _buildGridBookCard(book, isBookmarked);
      },
    );
  }

  // GRID BOOK CARD
  Widget _buildGridBookCard(BookItem book, bool isBookmarked) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: book.categoryColor.withAlpha(80),
          width: 1.2,
        ),
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
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openBookViewer(book),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BOOK COVER FRAME (Fills Box Completely)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        book.pdfUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: book.pdfUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorWidget: (context, url, error) =>
                                    _buildDefaultBookCover(book),
                                placeholder: (context, url) =>
                                    _buildDefaultBookCover(book),
                              )
                            : _buildDefaultBookCover(book),

                        // EMBLEM BADGE
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(1.8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                AssetPaths.beeBeyondEmblem,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.spa_rounded,
                                        size: 14, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),

                        // BOOKMARK
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _toggleBookmark(book.id),
                            child: Container(
                              padding: const EdgeInsets.all(3.5),
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: isBookmarked
                                    ? AppColors.primary
                                    : AppColors.textHint,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatAuthorName(book.author),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // READ BUTTON
                SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    onPressed: () => _openBookViewer(book),
                    icon: const Icon(Icons.auto_stories_rounded,
                        color: Colors.white, size: 13),
                    label: const Text(
                      'READ BOOK',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
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
}

// DEDICATED 2x2 CATEGORY BOOK GRID SCREEN
class BookCategoryGridScreen extends StatelessWidget {
  final String categoryName;
  final List<BookItem> books;
  final Set<String> bookmarkedIds;
  final ValueChanged<String> onToggleBookmark;
  final ValueChanged<BookItem> onOpenBook;

  const BookCategoryGridScreen({
    super.key,
    required this.categoryName,
    required this.books,
    required this.bookmarkedIds,
    required this.onToggleBookmark,
    required this.onOpenBook,
  });

  String _formatAuthorName(String raw) {
    final clean = raw.replaceAll(RegExp(r'^By\s+', caseSensitive: false), '').trim();
    if (clean.isEmpty) return 'By Bee Beyonnd Vault';
    return 'By $clean';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: categoryName,
      ),
      body: books.isEmpty
          ? const Center(
              child: Text(
                'No books found in this category.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                final isBookmarked = bookmarkedIds.contains(book.id);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: book.categoryColor.withAlpha(80),
                      width: 1.2,
                    ),
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
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onOpenBook(book),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // COVER FRAME (Fills Container Completely)
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    book.pdfUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: book.pdfUrl,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            errorWidget:
                                                (context, url, error) =>
                                                    _buildGridFallback(book),
                                            placeholder: (context, url) =>
                                                _buildGridFallback(book),
                                          )
                                        : _buildGridFallback(book),

                                    // BEE BEYONND EMBLEM ICON BADGE
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        padding: const EdgeInsets.all(1.8),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            AssetPaths.beeBeyondEmblem,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                        Icons.spa_rounded,
                                                        size: 14,
                                                        color:
                                                            AppColors.primary),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // BOOKMARK
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () =>
                                            onToggleBookmark(book.id),
                                        child: Container(
                                          padding: const EdgeInsets.all(3.5),
                                          decoration: const BoxDecoration(
                                            color: Colors.white70,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isBookmarked
                                                ? Icons.bookmark_rounded
                                                : Icons
                                                    .bookmark_border_rounded,
                                            color: isBookmarked
                                                ? AppColors.primary
                                                : AppColors.textHint,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatAuthorName(book.author),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // READ BUTTON
                            SizedBox(
                              height: 32,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                ),
                                onPressed: () => onOpenBook(book),
                                icon: const Icon(Icons.auto_stories_rounded,
                                    color: Colors.white, size: 14),
                                label: const Text(
                                  'READ BOOK',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildGridFallback(BookItem book) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            book.categoryColor,
            book.categoryColor.withAlpha(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 36),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
