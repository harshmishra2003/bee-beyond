import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/razorpay_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_pdf_book_viewer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/status_dialog.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../membership/presentation/providers/expiry_provider.dart';
import '../../domain/entities/book_item.dart';
import '../providers/library_provider.dart';
import '../providers/purchased_books_provider.dart';
import '../../../orders/domain/entities/receipt_entity.dart';
import '../../../../core/widgets/three_d_button.dart';

class MaterialScreen extends ConsumerStatefulWidget {
  const MaterialScreen({super.key});

  @override
  ConsumerState<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends ConsumerState<MaterialScreen> {
  String _selectedCategory = 'All';
  String _selectedAccessFilter = 'All'; // 'All', 'Free', 'Paid', 'Membership'
  final Set<String> _bookmarkedIds = {};
  final Set<String> _purchasedBookIds = {};

  bool _isLottieActive = true;
  DateTime? _dataResponseTime;
  Timer? _postResponseTimer;
  RazorpayService? _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
  }

  @override
  void dispose() {
    _postResponseTimer?.cancel();
    _razorpayService?.dispose();
    super.dispose();
  }

  bool _hasAccess(BookItem book) {
    if (book.accessType == 'free') return true;
    if (ref.read(purchasedBooksProvider).contains(book.id) || book.isPurchased) return true;
    if (book.accessType == 'membership') {
      final activePass = ref.read(activePassProvider);
      return activePass != null && !activePass.isExpired;
    }
    return false;
  }

  void _handleBookTap(BookItem book) {
    if (_hasAccess(book)) {
      _openBookViewer(book, isPreviewMode: false);
    } else if (book.accessType == 'membership') {
      _showMembershipRequiredDialog(book);
    } else if (book.accessType == 'paid') {
      // Show preview trailer first, then purchase dialog if they want
      _openBookViewer(book, isPreviewMode: true);
    } else {
      _openBookViewer(book, isPreviewMode: false);
    }
  }

  void _openBookViewer(BookItem book, {bool isPreviewMode = false}) async {
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
            title: detailedBook.title.isNotEmpty ? detailedBook.title : book.title,
            pdfUrl: detailedBook.pdfUrl.isNotEmpty ? detailedBook.pdfUrl : book.pdfUrl,
            subtitle: '${detailedBook.author} • ${detailedBook.category}',
            description: detailedBook.description.isNotEmpty ? detailedBook.description : book.description,
            samplePagesContent: detailedBook.samplePagesContent.isNotEmpty ? detailedBook.samplePagesContent : book.samplePagesContent,
            isPreviewMode: isPreviewMode,
          );
          
          if (isPreviewMode) {
             _showDelayedPurchaseSheet(book);
          }
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
        isPreviewMode: isPreviewMode,
      );
      if (isPreviewMode) {
         _showDelayedPurchaseSheet(book);
      }
    }
  }

  void _showDelayedPurchaseSheet(BookItem book) {
      Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
             _showBookPurchaseSheet(book);
          }
      });
  }

  void _showMembershipRequiredDialog(BookItem book) {
    StatusDialog.show(
      context,
      title: 'VIP Membership Required 👑',
      description:
          '${book.title} is an exclusive VIP study handbook.\n\nActivate a Bee Beyonnd VIP Membership Pass to unlock unlimited 24/7 reading access to all premium books and materials!',
      isSuccess: false,
      actionText: 'EXPLORE VIP PLANS',
      onAction: () {
        context.push(RoutePaths.membership);
      },
    );
  }

  void _showBookPurchaseSheet(BookItem book) {
    final user = ref.read(authStateProvider).user;
    final customerName = user?.name.isNotEmpty == true ? user!.name : 'Valued Customer';
    final customerEmail = user?.email.isNotEmpty == true ? user!.email : 'support@beebeyonnd.in';
    final customerPhone = user?.phone.isNotEmpty == true ? user!.phone : '9999999999';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // BOOK OVERVIEW HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 110,
                    child: book.pdfUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: book.pdfUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                _buildDefaultBookCover(book),
                          )
                        : _buildDefaultBookCover(book),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'INDIVIDUAL E-BOOK',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0369A1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.epilogue(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatAuthorName(book.author),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                          const SizedBox(width: 2),
                          Text('${book.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(width: 10),
                          Text('${book.totalPages} Pages • ${book.size}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),

            Text(
              'Synopsis & Overview',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  book.description.isNotEmpty
                      ? book.description
                      : 'Lifetime permanent access to certified digital study handbook with downloadable PDF notes and clinical diagnostic charts.',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF475569), height: 1.45),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // PRICING SUMMARY ROW
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total E-Book Price',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            CurrencyUtils.formatINR(book.price),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          if (book.originalPrice != null && book.originalPrice! > book.price) ...[
                            const SizedBox(width: 6),
                            Text(
                              CurrencyUtils.formatINR(book.originalPrice!),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (book.discountPercent > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${book.discountPercent}% OFF',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // BUY NOW BUTTON
            ThreeDButton(
              text: 'BUY E-BOOK NOW • ${CurrencyUtils.formatINR(book.price)}',
              icon: Icons.bolt_rounded,
              color: AppColors.primary,
              shadowColor: const Color(0xFF312E81),
              onPressed: () {
                Navigator.pop(ctx); // Close purchase sheet
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop(); // Also close PDF viewer if it's open underneath
                }
                _processBookPurchase(book, customerName, customerEmail, customerPhone);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processBookPurchase(
    BookItem book,
    String customerName,
    String customerEmail,
    String customerPhone,
  ) {
    _razorpayService?.onSuccess = (response) {
      if (!mounted) return;
      ref.read(purchasedBooksProvider.notifier).unlockBook(book.id);

      final receipt = ReceiptEntity(
        receiptId: 'REC-${DateTime.now().millisecondsSinceEpoch}',
        orderId: response.paymentId ?? 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Digital E-Book Purchase',
        type: 'DIGITAL_BOOK',
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        deliveryAddress: 'Instant Digital Access',
        items: [
          ReceiptItem(name: book.title, quantity: 1, unitPrice: book.price)
        ],
        subtotal: book.price,
        paymentMethod: 'Razorpay',
        date: DateTime.now(),
      );

      StatusDialog.show(
        context,
        title: 'Book Unlocked! 📖',
        description: 'Payment successful for "${book.title}". You now have lifetime reading access to this study handbook!',
        isSuccess: true,
        actionText: 'VIEW RECEIPT & READ',
        onAction: () {
          context.push(RoutePaths.receiptPreview, extra: receipt).then((_) {
              if (mounted) {
                  _openBookViewer(book, isPreviewMode: false);
              }
          });
        },
      );
    };

    _razorpayService?.onError = (response) {
      if (!mounted) return;
      final isDismissed = response.code == Razorpay.PAYMENT_CANCELLED;
      StatusDialog.show(
        context,
        title: isDismissed ? 'Purchase Cancelled' : 'Payment Failed',
        description: isDismissed
            ? 'Book purchase was cancelled. No amount was debited.'
            : (response.message ?? 'Transaction declined. Please try again.'),
        isSuccess: false,
        actionText: 'OK',
        onAction: () {},
      );
    };

    final amountPaise = (book.price * 100).toInt();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    _razorpayService?.openCheckout(
      keyId: 'rzp_test_beebeeyond',
      amountPaise: amountPaise > 0 ? amountPaise : 29900,
      gatewayOrderId: 'order_book_$timestamp',
      name: 'Bee Beyonnd Digital Store',
      description: book.title,
      contact: customerPhone,
      email: customerEmail,
      customerName: customerName,
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

  List<BookItem> _filterBooks(List<BookItem> books) {
    return books.where((b) {
      final matchesCategory = _selectedCategory == 'All' ||
          b.category.toLowerCase().contains(_selectedCategory.toLowerCase());

      bool matchesAccess = true;
      if (_selectedAccessFilter == 'Free') {
        matchesAccess = b.accessType == 'free';
      } else if (_selectedAccessFilter == 'Paid') {
        matchesAccess = b.accessType == 'paid';
      } else if (_selectedAccessFilter == 'Membership') {
        matchesAccess = b.accessType == 'membership';
      }

      return matchesCategory && matchesAccess;
    }).toList();
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
          purchasedBookIds: _purchasedBookIds,
          onToggleBookmark: _toggleBookmark,
          onOpenBook: _handleBookTap,
        ),
      ),
    );
  }

  Widget _buildBooksLottieLoadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFAF9FE),
            Color(0xFFFFFFFF),
            Color(0xFFF2F0FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Lottie.asset(
          AssetPaths.lottieBooks,
          width: 260,
          height: 260,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(purchasedBooksProvider); // trigger rebuilds when purchases change
    final booksAsync = ref.watch(booksAndMaterialsProvider);

    booksAsync.whenData((_) {
      if (_dataResponseTime == null) {
        _dataResponseTime = DateTime.now();
        _postResponseTimer?.cancel();
        _postResponseTimer = Timer(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _isLottieActive = false;
            });
          }
        });
      }
    });

    if (booksAsync.hasError && _dataResponseTime == null) {
      _dataResponseTime = DateTime.now();
      _postResponseTimer?.cancel();
      _postResponseTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isLottieActive = false;
          });
        }
      });
    }

    if (_isLottieActive && !booksAsync.hasValue) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9FE),
        body: _buildBooksLottieLoadingOverlay(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Books & Study Materials'),
      body: booksAsync.when(
        skipLoadingOnRefresh: true,
        data: (allBooks) {
          if (allBooks.isEmpty) {
            return _buildEmptyState();
          }

          final filteredBooks = _filterBooks(allBooks);
          final categories = _extractCategories(allBooks);
          final categoryMap = _groupBooksByCategory(filteredBooks);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ACCESS TIER CHIPS BAR ('All', 'Free', 'Paid', 'Membership')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildAccessFilterChip('All', 'All Books', Icons.apps_rounded),
                      const SizedBox(width: 8),
                      _buildAccessFilterChip('Free', 'Free', Icons.eco_rounded, color: const Color(0xFF059669)),
                      const SizedBox(width: 8),
                      _buildAccessFilterChip('Paid', 'E-Store', Icons.shopping_bag_rounded, color: const Color(0xFF6E4F9A)),
                      const SizedBox(width: 8),
                      _buildAccessFilterChip('Membership', 'VIP Pass', Icons.stars_rounded, color: const Color(0xFFD97706)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // CATEGORY FILTER CHIPS
                if (categories.length > 1)
                  SizedBox(
                    height: 36,
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                                width: 1.2,
                              ),
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
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // IF A SPECIFIC CATEGORY OR ACCESS TIER IS FILTERED
                if (_selectedCategory != 'All' || _selectedAccessFilter != 'All') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$_selectedAccessFilter $_selectedCategory Books',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                            '${filteredBooks.length} Books',
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
                  _buildCategoryGrid(filteredBooks),
                ] else ...[
                  // SHOW SECTIONAL HORIZONTAL LISTS FOR ALL CATEGORIES
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
    );
  }

  Widget _buildAccessFilterChip(String key, String label, IconData icon, {Color? color}) {
    final isSelected = _selectedAccessFilter == key;
    final chipColor = color ?? AppColors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAccessFilter = key;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? chipColor : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: chipColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: isSelected ? Colors.white : chipColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CATEGORY SECTION WITH AUTO-SLIDING HORIZONTAL SCROLLABLE LIST
  Widget _buildCategorySection({
    required String categoryName,
    required List<BookItem> books,
  }) {
    return _AutoSlidingCategorySection(
      categoryName: categoryName,
      books: books,
      bookmarkedIds: _bookmarkedIds,
      onToggleBookmark: _toggleBookmark,
      onOpenBook: _handleBookTap,
      onViewMore: () => _navigateToCategoryGrid(categoryName, books),
      buildBookCard: (book, isBookmarked) => _buildHorizontalBookCard(book, isBookmarked),
      buildViewMoreCard: (catName, catBooks) => _buildShiningViewMoreCard(
        categoryName: catName,
        books: catBooks,
      ),
    );
  }

  // HORIZONTAL BOOK CARD (WITH ACCESS BADGE & DYNAMIC PRICE)
  Widget _buildHorizontalBookCard(BookItem book, bool isBookmarked) {
    final unlocked = _hasAccess(book);

    return Container(
      width: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: book.categoryColor.withValues(alpha: 0.3),
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
          onTap: () => _handleBookTap(book),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // BOOK THUMBNAIL COVER FRAME
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
                child: SizedBox(
                  height: 128,
                  width: double.infinity,
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

                      // OVERLAID ACCESS TIER BADGE (Top-Left)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: unlocked
                                ? const Color(0xFF059669)
                                : (book.accessType == 'membership'
                                    ? const Color(0xFF6E4F9A)
                                    : const Color(0xFFD97706)),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Text(
                            unlocked
                                ? 'UNLOCKED'
                                : (book.accessType == 'membership' ? 'VIP PASS' : '₹${book.price.toInt()}'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.0,
                              fontWeight: FontWeight.w900,
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
                            color: Colors.black.withValues(alpha: 0.7),
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

              // BOOK DETAILS & ACTION BUTTON
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (book.accessType == 'paid' && !unlocked) ...[
                          Text(
                            CurrencyUtils.formatINR(book.price),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          if (book.originalPrice != null && book.originalPrice! > book.price) ...[
                            const SizedBox(width: 3),
                            Text(
                              CurrencyUtils.formatINR(book.originalPrice!),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Color(0xFF94A3B8),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ] else ...[
                          Text(
                            unlocked ? 'Free Access' : 'VIP Required',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: unlocked ? const Color(0xFF059669) : const Color(0xFF6E4F9A),
                              fontWeight: FontWeight.w700,
                            ),
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
      ),
    );
  }

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
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6), width: 1.5),
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
                  decoration: const BoxDecoration(
                    color: Colors.amberAccent,
                    shape: BoxShape.circle,
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

  Widget _buildDefaultBookCover(BookItem book) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            book.categoryColor,
            book.categoryColor.withValues(alpha: 0.7),
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
        childAspectRatio: 0.60,
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
    final unlocked = _hasAccess(book);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: book.categoryColor.withValues(alpha: 0.3),
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
          onTap: () => _handleBookTap(book),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BOOK COVER FRAME
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

                        // ACCESS BADGE
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? const Color(0xFF059669)
                                  : (book.accessType == 'membership'
                                      ? const Color(0xFF6E4F9A)
                                      : const Color(0xFFD97706)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              unlocked
                                  ? 'UNLOCKED'
                                  : (book.accessType == 'membership' ? 'VIP PASS' : '₹${book.price.toInt()}'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.0,
                                fontWeight: FontWeight.w900,
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

                // PRICE OR STATUS ROW
                if (book.accessType == 'paid' && !unlocked)
                  Row(
                    children: [
                      Text(
                        CurrencyUtils.formatINR(book.price),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      if (book.originalPrice != null && book.originalPrice! > book.price) ...[
                        const SizedBox(width: 4),
                        Text(
                          CurrencyUtils.formatINR(book.originalPrice!),
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),

                const SizedBox(height: 6),

                // DYNAMIC DUAL ACTION BUTTON
                SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: unlocked
                          ? AppColors.primary
                          : (book.accessType == 'membership'
                              ? const Color(0xFF6E4F9A)
                              : const Color(0xFF059669)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    onPressed: () => _handleBookTap(book),
                    icon: Icon(
                      unlocked
                          ? Icons.auto_stories_rounded
                          : (book.accessType == 'membership' ? Icons.stars_rounded : Icons.bolt_rounded),
                      color: Colors.white,
                      size: 13,
                    ),
                    label: Text(
                      unlocked
                          ? 'READ NOW'
                          : (book.accessType == 'membership' ? 'UNLOCK VIP' : 'BUY FOR ₹${book.price.toInt()}'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
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
  final Set<String> purchasedBookIds;
  final ValueChanged<String> onToggleBookmark;
  final ValueChanged<BookItem> onOpenBook;

  const BookCategoryGridScreen({
    super.key,
    required this.categoryName,
    required this.books,
    required this.bookmarkedIds,
    required this.purchasedBookIds,
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
                childAspectRatio: 0.60,
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
                      color: book.categoryColor.withValues(alpha: 0.3),
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
                            // COVER FRAME
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
            book.categoryColor.withValues(alpha: 0.7),
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

// AUTO-SLIDING HORIZONTAL CATEGORY SECTION WIDGET
class _AutoSlidingCategorySection extends StatefulWidget {
  final String categoryName;
  final List<BookItem> books;
  final Set<String> bookmarkedIds;
  final ValueChanged<String> onToggleBookmark;
  final ValueChanged<BookItem> onOpenBook;
  final VoidCallback onViewMore;
  final Widget Function(BookItem book, bool isBookmarked) buildBookCard;
  final Widget Function(String categoryName, List<BookItem> books) buildViewMoreCard;

  const _AutoSlidingCategorySection({
    required this.categoryName,
    required this.books,
    required this.bookmarkedIds,
    required this.onToggleBookmark,
    required this.onOpenBook,
    required this.onViewMore,
    required this.buildBookCard,
    required this.buildViewMoreCard,
  });

  @override
  State<_AutoSlidingCategorySection> createState() => _AutoSlidingCategorySectionState();
}

class _AutoSlidingCategorySectionState extends State<_AutoSlidingCategorySection> {
  late ScrollController _scrollController;
  Timer? _autoSlideTimer;
  bool _isForward = true;
  bool _isUserInteracting = false;
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAutoSlideTimer();
      }
    });
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (!mounted || _isUserInteracting || !_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (maxScroll <= 0) return;

      double targetScroll;
      if (_isForward) {
        targetScroll = currentScroll + 144.0;
        if (targetScroll >= maxScroll - 20) {
          targetScroll = maxScroll;
          _isForward = false;
        }
      } else {
        targetScroll = currentScroll - 144.0;
        if (targetScroll <= 20) {
          targetScroll = 0;
          _isForward = true;
        }
      }

      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _onPointerDown() {
    _isUserInteracting = true;
    _resumeTimer?.cancel();
  }

  void _onPointerUp() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _isUserInteracting = false;
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        widget.categoryName,
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
                onTap: widget.onViewMore,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'View All (${widget.books.length})',
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

        Listener(
          onPointerDown: (_) => _onPointerDown(),
          onPointerUp: (_) => _onPointerUp(),
          onPointerCancel: (_) => _onPointerUp(),
          child: SizedBox(
            height: 220,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.books.length + 1,
              itemBuilder: (context, index) {
                if (index < widget.books.length) {
                  final book = widget.books[index];
                  final isBookmarked = widget.bookmarkedIds.contains(book.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.buildBookCard(book, isBookmarked),
                  );
                } else {
                  return widget.buildViewMoreCard(widget.categoryName, widget.books);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }
}
