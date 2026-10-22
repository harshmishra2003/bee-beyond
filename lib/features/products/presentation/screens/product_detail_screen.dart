import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alert_manager.dart';
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
        data: (product) {
          final discount = product.discountPercent;
          final savingsAmount = (product.originalPrice != null && product.originalPrice! > product.price)
              ? (product.originalPrice! - product.price)
              : 0.0;

          final allImages = product.allImages;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Multi-Image Auto Carousel Banner
                _ProductImageCarousel(
                  images: allImages,
                  discount: discount,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & SubCategory Badges + Stock Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (product.subCategory != null && product.subCategory!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFC7D2FE)),
                                  ),
                                  child: Text(
                                    product.subCategory!,
                                    style: const TextStyle(
                                      color: Color(0xFF4338CA),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.inStock && product.effectiveMaxQuantity > 0
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: product.inStock && product.effectiveMaxQuantity > 0
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFCA5A5),
                              ),
                            ),
                            child: Text(
                              product.inStock && product.effectiveMaxQuantity > 0
                                  ? 'IN STOCK (${product.effectiveMaxQuantity} MAX / ORDER)'
                                  : 'OUT OF STOCK',
                              style: TextStyle(
                                color: product.inStock && product.effectiveMaxQuantity > 0
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFEF4444),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        product.title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Price & Discount Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            CurrencyUtils.formatINR(product.price),
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                          ),
                          if (product.originalPrice != null &&
                              product.originalPrice! > product.price) ...[
                            const SizedBox(width: 10),
                            Text(
                              CurrencyUtils.formatINR(product.originalPrice!),
                              style: AppTextStyles.titleMedium.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textHint,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$discount% OFF',
                              style: const TextStyle(
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (savingsAmount > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🎉 You save ${CurrencyUtils.formatINR(savingsAmount)} ($discount% OFF) on this item!',
                            style: const TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

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
                            _TrustBadgeItem(
                                icon: Icons.verified_rounded, label: '100% Genuine'),
                            _TrustBadgeItem(
                                icon: Icons.local_shipping_rounded,
                                label: 'Fast Delivery'),
                            _TrustBadgeItem(
                                icon: Icons.assignment_return_rounded,
                                label: 'Easy Returns'),
                          ],
                        ),
                      ),

                      const Divider(height: 28, color: AppColors.divider),
                      Text('Description & Healing Benefits',
                          style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(product.description,
                          style: AppTextStyles.bodyLarge.copyWith(height: 1.4)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: AppColors.error))),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) {
          final cartAsync = ref.watch(cartManagerProvider);
          final cartItems = cartAsync.value ?? [];
          final cartItemIndex = cartItems.indexWhere((i) => i.id == product.id);
          final bool isInCart = cartItemIndex >= 0;
          final int inCartQty = isInCart ? cartItems[cartItemIndex].quantity : 0;

          return SafeArea(
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
                  // Add To Cart Button / In Cart Status
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isInCart ? const Color(0xFF059669) : AppColors.primary,
                          width: 1.5,
                        ),
                        backgroundColor: isInCart ? const Color(0xFFECFDF5) : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (isInCart && inCartQty >= product.effectiveMaxQuantity) {
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
                          title: 'Item Added to Cart!',
                          message: '${product.title} added to cart.',
                          icon: Icons.shopping_bag_rounded,
                          backgroundColor: const Color(0xFF0F172A),
                          accentColor: const Color(0xFF10B981),
                          actionLabel: 'VIEW CART',
                          onAction: () => context.go(RoutePaths.cart),
                        );
                      },
                      icon: Icon(
                        isInCart ? Icons.verified_rounded : Icons.add_shopping_cart_rounded,
                        color: isInCart ? const Color(0xFF059669) : AppColors.primary,
                        size: 18,
                      ),
                      label: Text(
                        isInCart ? 'IN CART ✓ ($inCartQty)' : 'ADD TO CART',
                        style: TextStyle(
                          color: isInCart ? const Color(0xFF059669) : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Buy Now / View Cart Direct Checkout Button
                  Expanded(
                    child: ThreeDButton(
                      text: isInCart ? 'VIEW CART →' : '⚡ BUY NOW',
                      color: isInCart ? const Color(0xFF059669) : null,
                      shadowColor: isInCart ? const Color(0xFF064E3B) : null,
                      fontSize: 13,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        if (isInCart) {
                          context.go(RoutePaths.cart);
                        } else {
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
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

/// INTERACTIVE MULTI-IMAGE AUTO-CAROUSEL WIDGET WITH FULLSCREEN LIGHTBOX ZOOM
class _ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final int discount;

  const _ProductImageCarousel({
    required this.images,
    required this.discount,
  });

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.images.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!mounted || widget.images.length <= 1) return;

      if (_isForward) {
        if (_currentPage < widget.images.length - 1) {
          _currentPage++;
        } else {
          _isForward = false;
          _currentPage--;
        }
      } else {
        if (_currentPage > 0) {
          _currentPage--;
        } else {
          _isForward = true;
          _currentPage++;
        }
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openZoomLightbox(int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => _FullscreenImageZoomLightbox(
        images: widget.images,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesList = widget.images.isNotEmpty ? widget.images : [''];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x104B489B),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imagesList.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final url = imagesList[index];
                      return GestureDetector(
                        onTap: () => _openZoomLightbox(index),
                        child: Container(
                          color: const Color(0xFFF8FAFC),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              url.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: url,
                                      height: 260,
                                      width: double.infinity,
                                      fit: BoxFit.contain, // FULL IMAGE VISIBLE NO CROP
                                      placeholder: (context, url) => const SizedBox(
                                        height: 260,
                                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        height: 260,
                                        color: const Color(0xFFF8FAFC),
                                        child: const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.primary),
                                      ),
                                    )
                                  : Container(
                                      height: 260,
                                      color: const Color(0xFFF8FAFC),
                                      child: const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.primary),
                                    ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (widget.discount > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.discount}% OFF',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '100% GENUINE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Thumbnail selector row & Page Dots Indicator
        if (imagesList.length > 1) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  imagesList.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Thumbnail Previews
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: imagesList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final url = imagesList[index];
                final isSelected = _currentPage == index;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: url.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.textHint),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// FULLSCREEN PINCH-TO-ZOOM LIGHTBOX DIALOG
class _FullscreenImageZoomLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullscreenImageZoomLightbox({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullscreenImageZoomLightbox> createState() =>
      _FullscreenImageZoomLightboxState();
}

class _FullscreenImageZoomLightboxState
    extends State<_FullscreenImageZoomLightbox> {
  late PageController _lightboxPageController;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
    _lightboxPageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _lightboxPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Interactive Pinch-to-Zoom Image View
            PageView.builder(
              controller: _lightboxPageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _activeIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final url = widget.images[index];
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: url.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white54,
                              size: 64,
                            ),
                          )
                        : const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                  ),
                );
              },
            ),

            // Top Control Bar with Close Button & Counter
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_activeIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        Text(label,
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary)),
      ],
    );
  }
}
