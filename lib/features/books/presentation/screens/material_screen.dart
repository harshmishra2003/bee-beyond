import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_pdf_book_viewer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/book_item.dart';
import '../providers/books_provider.dart';

class MaterialScreen extends ConsumerStatefulWidget {
  const MaterialScreen({super.key});

  @override
  ConsumerState<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends ConsumerState<MaterialScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Bach Flower',
    'Ayurveda',
    'Vastu',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBookPdf(BookItem book) {
    AppPdfBookViewer.show(
      context,
      title: book.title,
      pdfUrl: book.pdfUrl,
      description: book.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksAndMaterialsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'E-Books & Handbooks'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(booksAndMaterialsProvider);
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER BANNER
              _buildHeaderBanner(),

              const SizedBox(height: 16),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search books, authors, diagnostic guides...',
                      hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textHint),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CATEGORY CHIPS
              _buildCategorySelector(),

              const SizedBox(height: 20),

              // BOOKS PRESENTATION
              booksAsync.when(
                data: (books) {
                  final filtered = books.where((b) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        b.title.toLowerCase().contains(_searchQuery) ||
                        b.author.toLowerCase().contains(_searchQuery) ||
                        b.description.toLowerCase().contains(_searchQuery);

                    final matchesCat = _selectedCategory == 'All' ||
                        b.category.toLowerCase().contains(_selectedCategory.toLowerCase());

                    return matchesSearch && matchesCat;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildBookCard(filtered[index]);
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (err, stack) => _buildErrorState(err.toString()),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'DIGITAL LIBRARY & HANDBOOKS',
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Official Study Handbooks & Manuals',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Access verified diagnostic reference books, clinical protocols, and PDF handbooks.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFFCBD5E1),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (val) {
              if (val) {
                setState(() {
                  _selectedCategory = cat;
                });
              }
            },
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              ),
            ),
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          );
        },
      ),
    );
  }

  Widget _buildBookCard(BookItem book) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openBookPdf(book),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // COVER IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: book.coverUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl,
                          width: 80,
                          height: 110,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 110,
                            color: const Color(0xFFF1F5F9),
                            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 110,
                            color: const Color(0xFF1E293B),
                            child: const Icon(Icons.menu_book_rounded, color: Colors.amber, size: 36),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 110,
                          color: const Color(0xFF1E293B),
                          child: const Icon(Icons.menu_book_rounded, color: Colors.amber, size: 36),
                        ),
                ),
                const SizedBox(width: 14),

                // DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.category,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${book.rating}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Author: ${book.author} • ${book.pages} Pages',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            book.isPaid ? CurrencyUtils.formatINR(book.price) : 'FREE ACCESS',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: book.isPaid ? AppColors.primary : const Color(0xFF10B981),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _openBookPdf(book),
                            icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                            label: Text(
                              'Read PDF',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.menu_book_rounded, size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'No Handbooks Found',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or category filters.',
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
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load study handbooks',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
