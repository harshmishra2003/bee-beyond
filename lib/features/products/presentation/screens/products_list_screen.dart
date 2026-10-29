import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../routing/route_paths.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/managers/cart_manager.dart';
import '../providers/product_provider.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'Popularity';

  bool _isLottieActive = true;
  DateTime? _dataResponseTime;
  Timer? _postResponseTimer;

  int _recommendationIndex = 0;
  Timer? _recommendationTimer;

  static const List<String> _rotatingRecommendations = [
    "Search 'Sacred White Feather'...",
    "Search 'Artisanal Aroma Soap'...",
    "Search 'Botanical Soy Candle'...",
    "Search 'Shree Laxmi Yantra'...",
    "Search 'Tibetan Singing Bowl'...",
    "Search 'Bach Flower Drops'...",
    "Search 'Ayurvedic Remedies'...",
    "Search 'Reiki Cleansed Crystals'...",
  ];

  @override
  void initState() {
    super.initState();
    _startRecommendationTimer();
  }

  void _startRecommendationTimer() {
    _recommendationTimer?.cancel();
    _recommendationTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (mounted) {
        setState(() {
          _recommendationIndex = (_recommendationIndex + 1) % _rotatingRecommendations.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _recommendationTimer?.cancel();
    _postResponseTimer?.cancel();
    super.dispose();
  }

  static const List<Map<String, dynamic>> _categoryData = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'emoji': '✨'},
    {'name': 'Ayurvedic Upchar', 'icon': Icons.spa_rounded, 'emoji': '🌿'},
    {'name': 'Bach Flower', 'icon': Icons.local_florist_rounded, 'emoji': '🌸'},
    {'name': 'Sacred Yantras', 'icon': Icons.auto_awesome_mosaic_rounded, 'emoji': '🕉️'},
    {'name': 'Aroma & Sound', 'icon': Icons.spatial_audio_off_rounded, 'emoji': '🕯️'},
    {'name': 'Reiki & Crystals', 'icon': Icons.diamond_rounded, 'emoji': '📿'},
    {'name': 'Counselling Services', 'icon': Icons.support_agent_rounded, 'emoji': '🩺'},
    {'name': 'Life Coaching', 'icon': Icons.psychology_rounded, 'emoji': '💡'},
    {'name': 'Alternative Medicine', 'icon': Icons.medication_liquid_rounded, 'emoji': '🧪'},
    {'name': 'Nutrition', 'icon': Icons.restaurant_rounded, 'emoji': '🥗'},
  ];

  void _openCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Header Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.amberAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Holistic Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Filter sacred remedies & tools',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFC7D2FE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedCategory != 'All')
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() => _selectedCategory = 'All');
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Categories List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _categoryData.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _categoryData[index];
                  final catName = item['name'] as String;
                  final emoji = item['emoji'] as String;
                  final isSelected =
                      _selectedCategory.toLowerCase() == catName.toLowerCase();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = catName;
                      });
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              catName,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 22)
                          else
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textHint, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    final cartAsync = ref.watch(cartManagerProvider);
    final cartItems = cartAsync.value ?? [];
    final cartCount = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 22),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go(RoutePaths.home);
              }
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BEE BEYONND',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6E4F9A),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Wellness And Healing Store',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF475569), size: 22),
            onPressed: () {},
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF475569), size: 22),
                onPressed: () => context.go(RoutePaths.cart),
              ),
              if (cartCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => context.push(RoutePaths.profile),
            child: const CircleAvatar(
              radius: 15,
              backgroundColor: Color(0xFFEEF2FF),
              child: Icon(Icons.person_rounded, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Rotating Recommendation Animated Hint Text
                      if (_searchQuery.isEmpty)
                        IgnorePointer(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.2),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            ),
                            child: Text(
                              _rotatingRecommendations[_recommendationIndex],
                              key: ValueKey(_recommendationIndex),
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      TextField(
                        onChanged: (val) {
                          setState(() => _searchQuery = val.trim());
                        },
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _searchQuery = ''),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 16),
                    ),
                  )
                else
                  const Icon(Icons.mic_rounded, color: Color(0xFF64748B), size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _openCategoryFilterSheet,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChipsBar(int totalCount) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categoryData.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _categoryData[index];
          final catName = item['name'] as String;
          final emoji = item['emoji'] as String;
          final isSelected =
              _selectedCategory.toLowerCase() == catName.toLowerCase();

          final label = catName == 'All' ? 'All Curations ($totalCount)' : catName;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = catName);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }





  Widget _buildProductsLottieLoadingOverlay() {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE6F4EA), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF006A37),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'WELLNESS ORGANIC STORE',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: const Color(0xFF006A37),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE6F4EA), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A006A37),
                      blurRadius: 30,
                      spreadRadius: 4,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Lottie.asset(
                  AssetPaths.lottieProductsLoading,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shopping_bag_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Loading Organic Store...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fetching Ayurvedic remedies, teas, Bach drops & wellness products',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    productsAsync.whenData((_) {
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

    if (productsAsync.hasError && _dataResponseTime == null) {
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

    if (_isLottieActive && !productsAsync.hasValue) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9FE),
        body: _buildProductsLottieLoadingOverlay(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // TOP HEADER BAR
            _buildTopAppBar(),

            // SCROLLABLE BODY
            Expanded(
              child: productsAsync.when(
                skipLoadingOnRefresh: true,
                data: (products) {
                  if (products.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final cartAsync = ref.watch(cartManagerProvider);
                  final cartItems = cartAsync.value ?? [];

                  final filteredProducts = products.where((p) {
                    final matchesCategory = _selectedCategory == 'All' ||
                        p.category.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
                        _selectedCategory.toLowerCase().contains(p.category.toLowerCase()) ||
                        p.title.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
                        p.description.toLowerCase().contains(_selectedCategory.toLowerCase());

                    final q = _searchQuery.toLowerCase();
                    final matchesQuery = q.isEmpty ||
                        p.title.toLowerCase().contains(q) ||
                        p.description.toLowerCase().contains(q) ||
                        p.category.toLowerCase().contains(q);

                    return matchesCategory && matchesQuery;
                  }).toList();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(allProductsProvider);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SEARCH & FILTER BAR
                          _buildSearchBar(),

                          const SizedBox(height: 12),

                          // HORIZONTAL CATEGORY CHIPS BAR
                          _buildCategoryChipsBar(products.length),

                          const SizedBox(height: 16),

                          // CURATED OFFERINGS SECTION HEADLINE & SORT
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Curated Offerings',
                                    style: GoogleFonts.epilogue(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${filteredProducts.length} of ${products.length}',
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                initialValue: _sortBy,
                                onSelected: (val) {
                                  setState(() => _sortBy = val);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _sortBy,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.expand_more_rounded, size: 16, color: Color(0xFF334155)),
                                    ],
                                  ),
                                ),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'Popularity', child: Text('Popularity')),
                                  PopupMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                                  PopupMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
                                  PopupMenuItem(value: 'Highest Rated', child: Text('Highest Rated')),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // 6. 2-COLUMN RESPONSIVE PRODUCT GRID
                          filteredProducts.isNotEmpty
                              ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    final screenWidth = constraints.maxWidth;
                                    int crossAxisCount = 2;
                                    double childAspectRatio = 0.62;

                                    if (screenWidth >= 1200) {
                                      crossAxisCount = 5;
                                      childAspectRatio = 0.74;
                                    } else if (screenWidth >= 900) {
                                      crossAxisCount = 4;
                                      childAspectRatio = 0.70;
                                    } else if (screenWidth >= 600) {
                                      crossAxisCount = 3;
                                      childAspectRatio = 0.66;
                                    } else if (screenWidth <= 360) {
                                      crossAxisCount = 2;
                                      childAspectRatio = 0.55;
                                    } else {
                                      crossAxisCount = 2;
                                      childAspectRatio = 0.62;
                                    }

                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: childAspectRatio,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: filteredProducts.length,
                                      itemBuilder: (context, index) {
                                        final product = filteredProducts[index];
                                        final cartItemIndex = cartItems.indexWhere((i) =>
                                            i.id == product.id ||
                                            i.id.startsWith(product.id) ||
                                            i.title.startsWith(product.title));
                                        final bool isInCart = cartItemIndex >= 0;
                                        final int cartQuantity =
                                            isInCart ? cartItems[cartItemIndex].quantity : 0;

                                        return ProductCard(
                                          title: product.title,
                                          category: product.category,
                                          imageUrl: product.imageUrl,
                                          price: product.price,
                                          originalPrice: product.originalPrice,
                                          unitType: product.unitType,
                                          isInCart: isInCart,
                                          cartQuantity: cartQuantity,
                                          onTap: () {
                                            debugPrint('🛍️ [PRODUCT CLICKED] ID: ${product.id}, Name: "${product.title}", Price: ₹${product.price}');
                                            context.push('${RoutePaths.productDetail}?id=${product.id}');
                                          },
                                          onAddToCart: () {
                                            if (isInCart && cartQuantity >= product.effectiveMaxQuantity) {
                                              AppAlertManager.showFloatingToast(
                                                context,
                                                title: 'Maximum Limit Reached',
                                                message:
                                                    'Only ${product.effectiveMaxQuantity} unit(s) allowed per order for ${product.title}.',
                                                icon: Icons.info_outline_rounded,
                                                backgroundColor: const Color(0xFF0F172A),
                                                accentColor: const Color(0xFFF59E0B),
                                              );
                                              return;
                                            }

                                            ref.read(cartManagerProvider.notifier).addToCart(
                                                  CartItemEntity(
                                                    id: product.id,
                                                    title: product.title,
                                                    imageUrl: product.imageUrl,
                                                    price: product.price,
                                                    quantity: 1,
                                                    maxAllowedQuantity: product.effectiveMaxQuantity,
                                                  ),
                                                );
                                            AppAlertManager.showFloatingToast(
                                              context,
                                              title: 'Added to Cart!',
                                              message: '${product.title} added to cart.',
                                              icon: Icons.shopping_bag_rounded,
                                              backgroundColor: const Color(0xFF0F172A),
                                              accentColor: const Color(0xFF10B981),
                                              actionLabel: 'VIEW CART',
                                              onAction: () => context.go(RoutePaths.cart),
                                            );
                                          },
                                          onBuyNow: () {
                                            debugPrint('⚡ [BUY NOW CLICKED] Direct checkout for product: "${product.title}" (ID: ${product.id}), Price: ₹${product.price}');
                                            context.push(
                                              RoutePaths.checkout,
                                              extra: CartItemEntity(
                                                id: product.id,
                                                title: product.title,
                                                imageUrl: product.imageUrl,
                                                price: product.price,
                                                quantity: 1,
                                                maxAllowedQuantity: product.effectiveMaxQuantity,
                                              ),
                                            );
                                          },
                                          onViewCart: () {
                                            context.go(RoutePaths.cart);
                                          },
                                          onIncrementQuantity: () {
                                            ref.read(cartManagerProvider.notifier).updateQuantity(
                                                product.id, cartQuantity + 1);
                                          },
                                          onDecrementQuantity: () {
                                            ref.read(cartManagerProvider.notifier).updateQuantity(
                                                product.id, cartQuantity - 1);
                                          },
                                        );
                                      },
                                    );
                                  },
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Icon(Icons.inventory_2_outlined,
                                            size: 48, color: AppColors.textHint),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No healing products found matching your search.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, stack) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: AppColors.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Icons.inventory_2_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Healing Products Available Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our store team is stocking organic Bach flower drops, Ayurvedic herbal teas, and Vastu tools. Check back soon!',
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
