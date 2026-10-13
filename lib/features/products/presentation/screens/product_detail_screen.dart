import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../../routing/route_paths.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/managers/cart_manager.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Product Details'),
      body: productAsync.when(
        data: (product) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Banner
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: 270,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 270,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '100% GENUINE AYURVEDIC',
                        style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          CurrencyUtils.formatINR(product.price),
                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900),
                        ),
                        if (product.originalPrice != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            CurrencyUtils.formatINR(product.originalPrice!),
                            style: AppTextStyles.titleMedium.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // TRUST ASSURANCE BADGES
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TrustBadgeItem(icon: Icons.verified_rounded, label: 'Genuine'),
                          _TrustBadgeItem(icon: Icons.local_shipping_rounded, label: 'Fast Delivery'),
                          _TrustBadgeItem(icon: Icons.assignment_return_rounded, label: 'Easy Returns'),
                        ],
                      ),
                    ),

                    const Divider(height: 28, color: AppColors.divider),
                    Text('Description & Healing Benefits', style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(product.description, style: AppTextStyles.bodyLarge.copyWith(height: 1.4)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x184B489B),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Add To Cart Button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
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
                    icon: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.primary, size: 18),
                    label: const Text('ADD TO CART', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ),

                const SizedBox(width: 10),

                // Buy Now Direct Checkout Button
                Expanded(
                  child: ThreeDButton(
                    text: '⚡ BUY NOW',
                    fontSize: 13,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: () {
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
                  ),
                ),
              ],
            ),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _TrustBadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadgeItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      ],
    );
  }
}
