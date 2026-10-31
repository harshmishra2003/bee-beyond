import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../routing/route_paths.dart';

enum SearchItemType { course, remedy, vastu, service, book }

class SearchResultItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final SearchItemType type;
  final double? price;
  final String? extraInfo;
  final String route;
  final String? imageUrl;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.type,
    this.price,
    this.extraInfo,
    required this.route,
    this.imageUrl,
  });

  String get typeLabel {
    switch (type) {
      case SearchItemType.course:
        return '🎓 COURSE';
      case SearchItemType.remedy:
        return '🌿 REMEDY';
      case SearchItemType.vastu:
        return '🔮 VASTU';
      case SearchItemType.service:
        return '🛠️ SERVICE';
      case SearchItemType.book:
        return '📚 BOOK';
    }
  }

  Color get typeColor {
    switch (type) {
      case SearchItemType.course:
        return const Color(0xFF4338CA);
      case SearchItemType.remedy:
        return const Color(0xFF059669);
      case SearchItemType.vastu:
        return const Color(0xFFD97706);
      case SearchItemType.service:
        return const Color(0xFF0288D1);
      case SearchItemType.book:
        return const Color(0xFF7C3AED);
    }
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<String> _recentSearches = [];
  bool _isLoadingHistory = true;

  // Search Dataset Across All Features
  static const List<SearchResultItem> _allSearchData = [
    SearchResultItem(
      id: 'c_1',
      title: 'Certified Bach Flower Therapy & Healing Course',
      category: 'Bach Flower',
      description: 'Comprehensive online certification in Bach Flower Remedies and emotional wellness.',
      type: SearchItemType.course,
      price: 2499.0,
      extraInfo: '24 Hours',
      route: '${RoutePaths.courseDetail}?id=c_1',
    ),
    SearchResultItem(
      id: 'c_2',
      title: 'Ayurvedic Lifestyle & Drugless Upchar Diploma',
      category: 'Ayurvedic Upchar',
      description: 'Ancient Indian healing wisdom, Prakriti diagnosis, and drugless remedies.',
      type: SearchItemType.course,
      price: 3999.0,
      extraInfo: '32 Hours',
      route: '${RoutePaths.courseDetail}?id=c_2',
    ),
    SearchResultItem(
      id: 'c_3',
      title: 'Mind & Life Coaching Masterclass',
      category: 'Counselling',
      description: 'Transformative emotional counselling skills and life coaching practices.',
      type: SearchItemType.course,
      price: 2999.0,
      extraInfo: '20 Hours',
      route: '${RoutePaths.courseDetail}?id=c_3',
    ),
    SearchResultItem(
      id: 'c_6',
      title: 'Advanced Vastu Shastra Certification',
      category: 'Vastu',
      description: 'In-depth Vastu corrections without demolition for spaces.',
      type: SearchItemType.course,
      price: 4999.0,
      extraInfo: '40 Hours',
      route: '${RoutePaths.courseDetail}?id=c_6',
    ),
    SearchResultItem(
      id: 'p_1',
      title: 'Original Bach Rescue Remedy Drops (20ml)',
      category: 'Remedies',
      description: 'Natural emergency stress relief formula made from original Bach flower essences.',
      type: SearchItemType.remedy,
      price: 850.0,
      extraInfo: 'In Stock',
      route: '${RoutePaths.productDetail}?id=p_1',
    ),
    SearchResultItem(
      id: 'p_2',
      title: 'Brass Brass Vastu Pyramid Set (9 Pyramids)',
      category: 'Vastu Products',
      description: 'Energized brass pyramid set for home and office direction corrections.',
      type: SearchItemType.vastu,
      price: 1499.0,
      extraInfo: 'In Stock',
      route: '${RoutePaths.productDetail}?id=p_2',
    ),
    SearchResultItem(
      id: 'p_3',
      title: 'Aura Cleansing & Energy Healing Oil (50ml)',
      category: 'Healing Oils',
      description: 'Infused herbal essential oil for chakra balancing and negative energy removal.',
      type: SearchItemType.remedy,
      price: 650.0,
      extraInfo: 'In Stock',
      route: '${RoutePaths.productDetail}?id=p_3',
    ),
    SearchResultItem(
      id: 's_1',
      title: 'Personalized Vastu Consultation',
      category: 'Services',
      description: '1-on-1 virtual or on-site Vastu analysis for home or commercial property.',
      type: SearchItemType.service,
      price: 1999.0,
      extraInfo: 'Online Session',
      route: RoutePaths.services,
    ),
    SearchResultItem(
      id: 's_2',
      title: 'Emotional & Mind Counselling Session',
      category: 'Services',
      description: 'Private 45-minute therapy session with certified life coach.',
      type: SearchItemType.service,
      price: 1499.0,
      extraInfo: '45 Mins',
      route: RoutePaths.services,
    ),
    SearchResultItem(
      id: 'ws_101',
      title: 'Certified Sound Healing & 528Hz Binaural Masterclass',
      category: 'Workshops',
      description: 'Master sacred sound frequency activation, singing bowls, and chakra alignment.',
      type: SearchItemType.course,
      price: 1999.0,
      extraInfo: 'Certified Masterclass',
      route: RoutePaths.workshops,
    ),
  ];

  static const List<String> _popularCategories = [
    'Bach Flower',
    'Vastu Shastra',
    'Ayurveda',
    'Life Coaching',
    'Rescue Remedy',
    'Consultations',
    'Books',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load Recent Searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('recent_searches_history') ?? [];
    if (mounted) {
      setState(() {
        _recentSearches = list;
        _isLoadingHistory = false;
      });
    }
  }

  // Save Query to Recent Searches
  Future<void> _saveSearchQuery(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('recent_searches_history') ?? [];
    
    // Remove duplicate if exists and add to top
    list.removeWhere((item) => item.toLowerCase() == cleanQuery.toLowerCase());
    list.insert(0, cleanQuery);

    // Keep max 10 recent searches
    if (list.length > 10) {
      list = list.sublist(0, 10);
    }

    await prefs.setStringList('recent_searches_history', list);
    if (mounted) {
      setState(() {
        _recentSearches = list;
      });
    }
  }

  // Remove Single Recent Search
  Future<void> _removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('recent_searches_history') ?? [];
    list.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

    await prefs.setStringList('recent_searches_history', list);
    if (mounted) {
      setState(() {
        _recentSearches = list;
      });
    }
  }

  // Clear All Recent Searches
  Future<void> _clearAllRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches_history');
    if (mounted) {
      setState(() {
        _recentSearches = [];
      });
    }
  }

  // Execute Search Selection
  void _onSelectItem(SearchResultItem item) {
    _saveSearchQuery(item.title);
    context.push(item.route);
  }

  void _onSelectRecentQuery(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(TextPosition(offset: query.length));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredResults = _allSearchData.where((item) {
      if (query.isEmpty) return false;
      return item.title.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 24),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            hintText: 'Search courses, remedies, vastu, services...',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13.5, fontWeight: FontWeight.w400),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (val) {
            setState(() {});
          },
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              _saveSearchQuery(val);
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: AppColors.textHint, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: query.isEmpty ? _buildRecentAndPopularSection() : _buildSearchResults(filteredResults),
    );
  }

  // Recent Searches & Popular Tags
  Widget _buildRecentAndPopularSection() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RECENT SEARCHES HEADER & LIST
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _clearAllRecentSearches,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppColors.error, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle, width: 1.2),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentSearches.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final searchItem = _recentSearches[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    dense: true,
                    leading: const Icon(Icons.north_west_rounded, size: 16, color: AppColors.textHint),
                    title: Text(
                      searchItem,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                      onPressed: () => _removeRecentSearch(searchItem),
                    ),
                    onTap: () => _onSelectRecentQuery(searchItem),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // POPULAR SEARCH CATEGORIES
          const Row(
            children: [
              Icon(Icons.local_fire_department_rounded, size: 18, color: Color(0xFFD97706)),
              SizedBox(width: 6),
              Text(
                'Popular Categories & Keywords',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularCategories.map((cat) {
              return GestureDetector(
                onTap: () => _onSelectRecentQuery(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        cat,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Active Search Results
  Widget _buildSearchResults(List<SearchResultItem> results) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                'No results found for "${_searchController.text}"',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try searching with different keywords like "Bach Flower", "Vastu", "Courses", "Oil", etc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = results[index];

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
              onTap: () => _onSelectItem(item),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Badge Icon Box
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.typeColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.typeLabel.split(' ').first,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.typeColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.typeLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.category,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                          if (item.price != null || item.extraInfo != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (item.price != null)
                                  Text(
                                    CurrencyUtils.formatINR(item.price!),
                                    style: TextStyle(
                                      color: item.typeColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                if (item.price != null && item.extraInfo != null)
                                  const Text(' • ', style: TextStyle(color: AppColors.textHint)),
                                if (item.extraInfo != null)
                                  Text(
                                    item.extraInfo!,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
