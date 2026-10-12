import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
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
      appBar: const CustomAppBar(title: 'Product Details'),
      body: productAsync.when(
        data: (product) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 260,
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
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
                    const Divider(height: 32, color: AppColors.divider),
                    Text('Description & Healing Benefits', style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(product.description, style: AppTextStyles.bodyLarge.copyWith(height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => Container(
          padding: const EdgeInsets.all(16),
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
          child: ThreeDButton(
            text: 'Add to Shopping Cart 🛒',
            fontSize: 15,
            padding: const EdgeInsets.symmetric(vertical: 13),
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
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
