import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../routing/route_paths.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/managers/cart_manager.dart';
import '../providers/product_provider.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Wellness & Healing Products'),
      body: productsAsync.when(
        data: (products) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              title: product.title,
              imageUrl: product.imageUrl,
              price: product.price,
              originalPrice: product.originalPrice,
              onTap: () => context.push('${RoutePaths.productDetail}?id=${product.id}'),
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
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }
}
