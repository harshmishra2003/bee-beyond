import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/widgets/custom_app_bar.dart';
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

  static const List<Map<String, dynamic>> _categoryData = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'color': Color(0xFF4338CA)},
    {'name': 'Ayurvedic Upchar', 'icon': Icons.spa_outlined, 'color': Color(0xFF059669)},
    {'name': 'Counselling Services', 'icon': Icons.support_agent_outlined, 'color': Color(0xFF4338CA)},
    {'name': 'Life Coaching', 'icon': Icons.psychology_outlined, 'color': Color(0xFF7C3AED)},
    {'name': 'Alternative Drugless Medicine', 'icon': Icons.medication_liquid_outlined, 'color': Color(0xFF0288D1)},
    {'name': 'Nutrition', 'icon': Icons.restaurant_outlined, 'color': Color(0xFFD97706)},
    {'name': 'Graphology', 'icon': Icons.edit_note_outlined, 'color': Color(0xFF4338CA)},
    {'name': 'Psychotherapy Modalities', 'icon': Icons.self_improvement_outlined, 'color': Color(0xFF7C3AED)},
    {'name': 'DMIT', 'icon': Icons.fingerprint_outlined, 'color': Color(0xFF0288D1)},
    {'name': 'Reiki', 'icon': Icons.auto_awesome_outlined, 'color': Color(0xFFD97706)},
    {'name': 'Astrology', 'icon': Icons.brightness_7_outlined, 'color': Color(0xFF7C3AED)},
    {'name': 'Jain Mantra Urja', 'icon': Icons.brightness_high_outlined, 'color': Color(0xFFD97706)},
    {'name': 'Buddhism', 'icon': Icons.filter_vintage_outlined, 'color': Color(0xFF059669)},
    {'name': 'Mind & Body Balance Modalities', 'icon': Icons.balance_outlined, 'color': Color(0xFF0288D1)},
    {'name': 'Spiritual Holistic Healing', 'icon': Icons.nature_people_outlined, 'color': Color(0xFF059669)},
    {'name': 'Health Wealth and Happiness Remedy', 'icon': Icons.card_giftcard_outlined, 'color': Color(0xFFD97706)},
    {'name': 'Aromatherapy Courses', 'icon': Icons.local_florist_outlined, 'color': Color(0xFF059669)},
    {'name': 'Personality & Motivational', 'icon': Icons.emoji_events_outlined, 'color': Color(0xFF4338CA)},
  ];

  void _openCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
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
                          'Product Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select holistic category filter',
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
                  final icon = item['icon'] as IconData;
                  final color = item['color'] as Color;
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
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) {
          setState(() => _searchQuery = val.trim());
        },
        style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search organic remedies, teas, Bach drops...',
          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.textHint, size: 18),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryChipsBar() {
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
          final icon = item['icon'] as IconData;
          final isSelected =
              _selectedCategory.toLowerCase() == catName.toLowerCase();

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = catName);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                  width: isSelected ? 1.8 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? Colors.amberAccent : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    catName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Wellness & Healing Products',
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary, size: 26),
            tooltip: 'All Categories',
            onPressed: _openCategoryFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productsAsync.when(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH BAR
                  _buildSearchBar(),

                  const SizedBox(height: 14),

                  // HORIZONTAL CATEGORY CHIPS BAR
                  _buildCategoryChipsBar(),

                  const SizedBox(height: 16),

                  // Header Count Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$_selectedCategory Products',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFC7D2FE)),
                            ),
                            child: Text(
                              '${filteredProducts.length}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedCategory != 'All' || _searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'All';
                              _searchQuery = '';
                            });
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.clear_rounded, size: 16, color: AppColors.textHint),
                              SizedBox(width: 4),
                              Text('Reset All',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Products Grid
                  filteredProducts.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.63,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
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
                              onTap: () => context.push(
                                  '${RoutePaths.productDetail}?id=${product.id}'),
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
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.inventory_2_outlined,
                                    size: 48, color: AppColors.textHint),
                                const SizedBox(height: 12),
                                Text(
                                  'No healing products found matching your search.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13.5),
                                ),
                              ],
                            ),
                          ),
                        ),

                  const SizedBox(height: 32),
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
