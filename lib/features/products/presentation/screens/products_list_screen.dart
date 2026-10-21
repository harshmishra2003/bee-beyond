import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  static const List<String> _productCategories = [
    'All',
    'Ayurvedic Upchar',
    'Counselling Services',
    'Life Coaching',
    'Alternative Drugless Medicine',
    'Nutrition',
    'Graphology',
    'Psychotherapy Modalities',
    'DMIT',
    'Reiki',
    'Astrology',
    'Jain Mantra Urja',
    'Buddhism',
    'Mind & Body Balance Modalities',
    'Spiritual Holistic Healing',
    'Health Wealth and Happiness Remedy',
    'Aromatherapy Courses',
    'Personality & Motivational',
  ];

  void _openCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Filter Products by Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (_selectedCategory != 'All')
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedCategory = 'All');
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _productCategories.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final cat = _productCategories[index];
                  final isSelected =
                      _selectedCategory.toLowerCase() == cat.toLowerCase();

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    title: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 22)
                        : const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textHint, size: 18),
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
            tooltip: 'Filter Categories',
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

          final filteredProducts = products.where((p) {
            if (_selectedCategory == 'All') return true;
            final selLower = _selectedCategory.toLowerCase();
            final titleLower = p.title.toLowerCase();
            final descLower = p.description.toLowerCase();
            final catLower = p.category.toLowerCase();

            return catLower.contains(selLower) ||
                selLower.contains(catLower) ||
                titleLower.contains(selLower) ||
                descLower.contains(selLower);
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
                  // Hamburger Filter Bar Trigger Banner
                  GestureDetector(
                    onTap: _openCategoryFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      child: Row(
                        children: [
                          const Icon(Icons.menu_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Product Category Filter',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textHint,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _selectedCategory,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFC7D2FE)),
                            ),
                            child: const Text(
                              'SELECT ☰',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header Count Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_selectedCategory Products (${filteredProducts.length})',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedCategory != 'All')
                        GestureDetector(
                          onTap: () => setState(() => _selectedCategory = 'All'),
                          child: const Row(
                            children: [
                              Icon(Icons.clear_rounded, size: 16, color: AppColors.textHint),
                              SizedBox(width: 4),
                              Text('Clear Filter',
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
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductCard(
                              title: product.title,
                              imageUrl: product.imageUrl,
                              price: product.price,
                              originalPrice: product.originalPrice,
                              onTap: () => context.push(
                                  '${RoutePaths.productDetail}?id=${product.id}'),
                              onAddToCart: () {
                                ref.read(cartManagerProvider.notifier).addToCart(
                                      CartItemEntity(
                                        id: product.id,
                                        title: product.title,
                                        imageUrl: product.imageUrl,
                                        price: product.price,
                                        quantity: 1,
                                      ),
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.title} added to cart!'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              onBuyNow: () {
                                ref.read(cartManagerProvider.notifier).addToCart(
                                      CartItemEntity(
                                        id: product.id,
                                        title: product.title,
                                        imageUrl: product.imageUrl,
                                        price: product.price,
                                        quantity: 1,
                                      ),
                                    );
                                context.push(RoutePaths.checkout);
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
                                  'No healing products found under "$_selectedCategory" yet.',
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
