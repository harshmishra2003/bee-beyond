import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class BookItem {
  final String id;
  final String title;
  final String author;
  final String category;
  final String size;
  final int totalPages;
  final double rating;
  final String description;
  final List<String> samplePagesContent;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.size,
    required this.totalPages,
    required this.rating,
    required this.description,
    required this.samplePagesContent,
  });

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'bach flower therapy':
        return const Color(0xFF059669);
      case 'vastu shastra':
        return const Color(0xFFD97706);
      case 'ayurveda':
        return const Color(0xFF4338CA);
      case 'graphology':
        return const Color(0xFF7C3AED);
      case 'drugless cure':
        return const Color(0xFF0288D1);
      default:
        return AppColors.primary;
    }
  }
}

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  String _selectedCategory = 'All';
  final Set<String> _downloadedBookIds = {'b_1'};
  final Set<String> _bookmarkedIds = {'b_1', 'b_3'};

  static const List<String> _categories = [
    'All',
    'Bach Flower Therapy',
    'Vastu Shastra',
    'Ayurveda',
    'Graphology',
    'Drugless Cure',
  ];

  static const List<BookItem> _allBooks = [
    BookItem(
      id: 'b_1',
      title: '38 Bach Flower Remedies Reference Chart & Diagnostic Guide',
      author: 'Dr. Edward Bach & Bee Beyond Vault',
      category: 'Bach Flower Therapy',
      size: '2.4 MB',
      totalPages: 12,
      rating: 4.9,
      description: 'Official clinical handbook detailing all 38 flower essences, emotional states classification, dosage preparation, and real patient case studies.',
      samplePagesContent: [
        'CHAPTER 1: INTRODUCTION TO BACH FLOWER REMEDIES\n\nDr. Edward Bach discovered that physical ailments often stem from emotional imbalances. The 38 flower essences are non-toxic, natural remedies that restore harmony to the human mind.\n\nKey Essence 1: Agrimony - Mental torture behind a brave face.\nKey Essence 2: Aspen - Fear of unknown origins and anxiety.\nKey Essence 3: Beech - Intolerance and critical behavior.',
        'CHAPTER 2: SELECTION & DOSAGE FORMULATION\n\nSelecting the right remedy requires acute observation of the patient\'s emotional disposition rather than physical symptoms.\n\nDosage Guidelines:\n• Mixing Bottles: Add 2 drops of each selected essence into a 30ml dropper bottle with pure spring water.\n• Frequency: Take 4 drops, 4 times daily under the tongue.',
        'CHAPTER 3: CLINICAL DIAGNOSIS & CASE STUDIES\n\nCase Study A: Acute panic and sudden shock.\nPrescription: Rescue Remedy + Star of Bethlehem + Rock Rose.\n\nOutcome: Patient reported emotional stabilization within 15 minutes of oral administration.',
        'CHAPTER 4: ADVANCED REMEDY COMBINATIONS\n\nFor chronic depression and deep grief, combine Mustard and Sweet Chestnut with Walnut for smooth life transition protection.',
      ],
    ),
    BookItem(
      id: 'b_2',
      title: 'Vastu Shastra Directions, 5 Elements & Non-Demolition Guide',
      author: 'Guruji Rajesh Vastu',
      category: 'Vastu Shastra',
      size: '4.1 MB',
      totalPages: 18,
      rating: 4.8,
      description: 'Comprehensive guide covering Panchatattva (5 Elements) balancing, direction alignments, bedroom placement, and pyramid remedies.',
      samplePagesContent: [
        'CHAPTER 1: THE FIVE ELEMENTS (PANCHATATTVA)\n\nVastu Shastra harmonizes Water, Fire, Earth, Air, and Space energies inside residential and commercial properties.\n\n• North-East (Eshanya): Water Element - Ideal for Meditation & Prayer.\n• South-East (Agneya): Fire Element - Ideal for Kitchen Placement.',
        'CHAPTER 2: NON-DEMOLITION VASTU REMEDIES\n\nWhen structural alterations are impossible, non-demolition remedies like Brass Pyramids, Helix Strips, and Color Tapes neutralize negative directional doshas.',
        'CHAPTER 3: BEDROOM & STUDY ROOM ALIGNMENTS\n\nMaster Bedroom should ideally be situated in the South-West (Nairutya) direction to ensure stability, financial growth, and family authority.',
      ],
    ),
    BookItem(
      id: 'b_3',
      title: 'Ayurvedic Dinacharya Daily Routine & Prakriti Handbook',
      author: 'Acharya Devraj Ji',
      category: 'Ayurveda',
      size: '3.2 MB',
      totalPages: 15,
      rating: 4.9,
      description: 'Ancient Ayurvedic lifestyle guide for Vata, Pitta, and Kapha constitution diagnosis, herbal cleanses, and daily dinacharya rituals.',
      samplePagesContent: [
        'CHAPTER 1: PRAKRITI DIAGNOSIS (DOSHAS)\n\nUnderstanding Vata (Air/Space), Pitta (Fire/Water), and Kapha (Water/Earth) is the foundation of Ayurvedic drugless healing.\n\n• Vata: Light, cold, dry, active.\n• Pitta: Hot, sharp, intense.\n• Kapha: Heavy, slow, stable, smooth.',
        'CHAPTER 2: MORNING DINACHARYA RITUALS\n\n1. Brahma Muhurta Waking (Before Sunrise).\n2. Ushapan: Drinking lukewarm water stored in a copper vessel.\n3. Jivha Nirlekhana: Tongue scraping to remove Ama toxins.',
        'CHAPTER 3: GUT HEALING & SEASONAL DIET\n\nEat according to your Agni (Digestive Fire). Avoid conflicting foods (Viruddha Ahara) like milk with citrus fruits or fish.',
      ],
    ),
    BookItem(
      id: 'b_4',
      title: 'Graphology Handwriting & Signature Analysis Basics',
      author: 'Dr. Vivek Anand',
      category: 'Graphology',
      size: '1.9 MB',
      totalPages: 10,
      rating: 4.7,
      description: 'Learn personality assessment through handwriting slant, pressure, loops, spacing, and signature stroke analysis.',
      samplePagesContent: [
        'CHAPTER 1: HANDWRITING SLANTS & EMOTIONS\n\n• Right Slant (Forward): Expressive, emotional, social personality.\n• Vertical Slant: Logical, controlled, analytical mind.\n• Left Slant (Backward): Reserved, cautious, introverted tendencies.',
        'CHAPTER 2: SIGNATURE ANALYSIS SECRETS\n\nA signature represents a person\'s public persona.\n\n• Underline with Dot: Confidence with caution.\n• Legible Signature: Transparency and open nature.',
      ],
    ),
    BookItem(
      id: 'b_5',
      title: 'Drugless Natural Cure Principles & Herbal Remedies',
      author: 'Bee Beyond Wellness Vault',
      category: 'Drugless Cure',
      size: '5.6 MB',
      totalPages: 24,
      rating: 4.9,
      description: 'Natural healing wisdom explaining fasting therapy, hydrotherapy, mud packs, and herbal compresses for chronic wellness.',
      samplePagesContent: [
        'CHAPTER 1: THE LAWS OF NATURAL HEALING\n\nDisease is the body\'s natural effort to eliminate accumulated toxic waste. Suppressing symptoms with heavy synthetic drugs leads to chronic conditions.',
        'CHAPTER 2: HYDROTHERAPY & MUD PACKS\n\nApplying cold mud packs to the abdomen relieves gut heat, improves peristalsis, and detoxifies the liver naturally.',
      ],
    ),
  ];

  void _openBookViewer(BookItem book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FlipBookViewerScreen(book: book),
      ),
    );
  }

  void _downloadBook(BookItem book) {
    if (_downloadedBookIds.contains(book.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${book.title}" is already downloaded in your offline library.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading "${book.title}" (${book.size})...'),
        backgroundColor: AppColors.primary,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _downloadedBookIds.add(book.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${book.title}" downloaded successfully! Saved to offline storage.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _allBooks.where((b) {
      if (_selectedCategory == 'All') return true;
      return b.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Books & Study Materials'),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // CATEGORY FILTER CHIPS
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
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

          // BOOKS LIST
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredBooks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                final isDownloaded = _downloadedBookIds.contains(book.id);
                final isBookmarked = _bookmarkedIds.contains(book.id);

                return _buildBookCard(book, isDownloaded, isBookmarked);
              },
            ),
          ),
        ],
      ),
    );
  }

  // BOOK CARD BUILDER
  Widget _buildBookCard(BookItem book, bool isDownloaded, bool isBookmarked) {
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
                // Book Cover Vector Box
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

                      // Action Buttons Row: READ BOOK & DOWNLOAD
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 34,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  elevation: 0,
                                ),
                                onPressed: () => _openBookViewer(book),
                                icon: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 16),
                                label: const Text(
                                  'READ BOOK',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF2F0FC),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: Icon(
                              isDownloaded ? Icons.file_download_done_rounded : Icons.file_download_rounded,
                              color: isDownloaded ? AppColors.success : AppColors.primary,
                              size: 18,
                            ),
                            onPressed: () => _downloadBook(book),
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
}

// REALISTIC 3D FLIP BOOK READER SCREEN
class _FlipBookViewerScreen extends StatefulWidget {
  final BookItem book;

  const _FlipBookViewerScreen({required this.book});

  @override
  State<_FlipBookViewerScreen> createState() => _FlipBookViewerScreenState();
}

class _FlipBookViewerScreenState extends State<_FlipBookViewerScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isDarkMode = false;
  double _fontSize = 14.5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.book.samplePagesContent.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.book.samplePagesContent;

    final bgColor = _isDarkMode ? const Color(0xFF1E1E2E) : const Color(0xFFFAF8F5);
    final paperColor = _isDarkMode ? const Color(0xFF28283D) : const Color(0xFFFFFDF9);
    final textColor = _isDarkMode ? const Color(0xFFCDD6F4) : const Color(0xFF2C2A54);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? const Color(0xFF181825) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _isDarkMode ? Colors.white : AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : AppColors.primary,
              ),
            ),
            Text(
              'Page ${_currentPage + 1} of ${pages.length}',
              style: TextStyle(
                fontSize: 11,
                color: _isDarkMode ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Font Size Decrease
          IconButton(
            icon: Icon(Icons.text_decrease_rounded, color: _isDarkMode ? Colors.white : AppColors.primary, size: 20),
            onPressed: () {
              if (_fontSize > 12) setState(() => _fontSize -= 1.0);
            },
          ),
          // Font Size Increase
          IconButton(
            icon: Icon(Icons.text_increase_rounded, color: _isDarkMode ? Colors.white : AppColors.primary, size: 20),
            onPressed: () {
              if (_fontSize < 22) setState(() => _fontSize += 1.0);
            },
          ),
          // Dark Mode Toggle
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: _isDarkMode ? Colors.amber : AppColors.primary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 3D FLIPPING PAGE VIEW CONTAINER
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (pageIndex) {
                  setState(() {
                    _currentPage = pageIndex;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double pageOffset = 0.0;
                      if (_pageController.position.haveDimensions) {
                        pageOffset = _pageController.page! - index;
                      } else {
                        pageOffset = (_currentPage - index).toDouble();
                      }

                      // Clamp between -1.0 and 1.0 for smooth rotation
                      pageOffset = pageOffset.clamp(-1.0, 1.0);

                      // REALISTIC 3D PAGE TURN MATRIX
                      final isRight = pageOffset > 0;
                      final angle = pageOffset * (math.pi / 2.2);

                      final matrix = Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateY(angle);

                      return Transform(
                        transform: matrix,
                        alignment: isRight ? Alignment.centerLeft : Alignment.centerRight,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: paperColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isDarkMode ? const Color(0xFF313244) : const Color(0xFFE2E0D8),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(_isDarkMode ? 80 : 25),
                            blurRadius: 12,
                            offset: const Offset(4, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Book Page Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'BEE BEYOND PUBLISHING',
                                style: TextStyle(
                                  color: widget.book.categoryColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: textColor.withAlpha(120),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(color: _isDarkMode ? Colors.white24 : const Color(0xFFE2E0D8), height: 20),

                          // Page Content Text
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                pages[index],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: _fontSize,
                                  height: 1.6,
                                  letterSpacing: 0.2,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ),
                          ),

                          // Footer Watermark
                          const Divider(height: 20, color: Colors.black12),
                          Center(
                            child: Text(
                              'Tap left or right / Swipe to flip pages',
                              style: TextStyle(
                                color: textColor.withAlpha(100),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // BOTTOM CONTROL BAR FOR PAGE FLIPPING
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _isDarkMode ? const Color(0xFF181825) : Colors.white,
              border: Border(top: BorderSide(color: _isDarkMode ? Colors.white12 : AppColors.borderSubtle)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Previous Page Button
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded, color: _currentPage > 0 ? AppColors.primary : AppColors.textHint),
                    onPressed: _currentPage > 0 ? _previousPage : null,
                  ),

                  // Page Progress Indicator & Slider
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.borderSubtle,
                            thumbColor: AppColors.primary,
                          ),
                          child: Slider(
                            value: _currentPage.toDouble(),
                            min: 0,
                            max: (pages.length - 1).toDouble(),
                            divisions: math.max(1, pages.length - 1),
                            onChanged: (val) {
                              final page = val.round();
                              _pageController.animateToPage(
                                page,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              );
                            },
                          ),
                        ),
                        Text(
                          'Page ${_currentPage + 1} of ${pages.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Next Page Button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _currentPage < pages.length - 1 ? AppColors.primary : AppColors.textHint,
                    ),
                    onPressed: _currentPage < pages.length - 1 ? _nextPage : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
