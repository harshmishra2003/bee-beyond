import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/book_item.dart';
import '../providers/books_provider.dart';
import '../widgets/book_detail_sheet.dart';
import 'category_books_view_all_screen.dart';

class MaterialScreen extends ConsumerStatefulWidget {
  const MaterialScreen({super.key});

  @override
  ConsumerState<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends ConsumerState<MaterialScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';

  static const List<String> _categoryFilters = [
    'All',
    'Top selling',
    'Ebooks for you',
    'Ayurvedic & Healing',
    'Vastu Manuals',
    'Top free',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBookTapped(BookItem book) {
    BookDetailSheet.show(context, book);
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksAndMaterialsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern Light Theme
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(booksAndMaterialsProvider);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // TOP SEARCH BAR (LIGHT THEME)
                _buildPlayBooksSearchBar(),

                const SizedBox(height: 14),

                // GENRES & CATEGORIES FILTER CHIPS
                _buildGenreFilterBar(),

                const SizedBox(height: 16),

                // BOOKS CONTENT
                booksAsync.when(
                  data: (allBooks) {
                    final filteredBooks = allBooks.where((b) {
                      if (_searchQuery.isEmpty) return true;
                      return b.title.toLowerCase().contains(_searchQuery) ||
                          b.author.toLowerCase().contains(_searchQuery) ||
                          b.description.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredBooks.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Group books by categories/sections
                    final Map<String, List<BookItem>> sections = {};

                    for (final book in filteredBooks) {
                      final cat = book.category.isNotEmpty ? book.category : 'Featured Ebooks';
                      sections.putIfAbsent(cat, () => []).add(book);
                    }

                    if (_searchQuery.isNotEmpty || _selectedCategoryFilter != 'All') {
                      final activeList = _selectedCategoryFilter == 'All'
                          ? filteredBooks
                          : filteredBooks.where((b) => b.category.toLowerCase().contains(_selectedCategoryFilter.toLowerCase())).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Search Results (${activeList.length})',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: activeList.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                            itemBuilder: (ctx, i) => _buildHorizontalCardTile(activeList[i]),
                          ),
                        ],
                      );
                    }

                    // Sectional Layout
                    return Column(
                      children: sections.entries.map((entry) {
                        return _buildSectionRow(
                          title: entry.key,
                          books: entry.value,
                          allCategoryBooks: allBooks.where((b) => b.category == entry.key).toList(),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (err, stack) => _buildErrorState(err.toString()),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayBooksSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSubtle, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Search Books & Handbooks',
                  hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13.5),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            else ...[
              const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.auto_stories_rounded, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenreFilterBar() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categoryFilters.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final filter = _categoryFilters[i];
          final isSelected = _selectedCategoryFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (val) {
              if (val) {
                setState(() {
                  _selectedCategoryFilter = filter;
                });
              }
            },
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            elevation: isSelected ? 2 : 0,
          );
        },
      ),
    );
  }

  Widget _buildSectionRow({
    required String title,
    required List<BookItem> books,
    required List<BookItem> allCategoryBooks,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION TITLE & SEE ALL ARROW
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 12, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              InkWell(
                onTap: () => CategoryBooksViewAllScreen.navigate(
                  context,
                  title,
                  allCategoryBooks.isNotEmpty ? allCategoryBooks : books,
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        // HORIZONTAL SCROLLING BOOKS LIST
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: books.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 14),
            itemBuilder: (ctx, i) {
              return _buildVerticalBookCard(books[i]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalBookCard(BookItem book) {
    return GestureDetector(
      onTap: () => _onBookTapped(book),
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COVER IMAGE
            AspectRatio(
              aspectRatio: 0.68,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Icon(Icons.book_rounded, color: Colors.amberAccent, size: 32),
                        ),
                      ),
                    ),
                  ),

                  // OWNED BADGE
                  if (book.isPurchased)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // TITLE
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: const Color(0xFF0F172A),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 3),

            // PRICES & RATING
            Row(
              children: [
                Text(
                  !book.isPaid
                      ? 'Free'
                      : (book.isPurchased ? 'Owned' : CurrencyUtils.formatINR(book.price)),
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (book.isPaid && !book.isPurchased && book.mrp > book.price) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      CurrencyUtils.formatINR(book.mrp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 9.5,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCardTile(BookItem book) {
    return GestureDetector(
      onTap: () => _onBookTapped(book),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: book.coverUrl,
                width: 60,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.author} • ${book.pages} Pages',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        !book.isPaid
                            ? 'Free'
                            : (book.isPurchased ? 'Owned' : CurrencyUtils.formatINR(book.price)),
                        style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (book.isPaid && !book.isPurchased && book.mrp > book.price) ...[
                        const SizedBox(width: 6),
                        Text(
                          CurrencyUtils.formatINR(book.mrp),
                          style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 10, decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.auto_stories_rounded, size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'No Books Found',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or genre filters.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load books',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(booksAndMaterialsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
