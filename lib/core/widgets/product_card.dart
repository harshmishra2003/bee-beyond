import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/asset_paths.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_utils.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final String category;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String unitType;
  final double rating;
  final String? tagLabel;
  final bool isInCart;
  final int cartQuantity;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback? onBuyNow;
  final VoidCallback? onViewCart;
  final VoidCallback? onIncrementQuantity;
  final VoidCallback? onDecrementQuantity;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.title,
    this.category = 'STORE',
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.unitType = '500g',
    this.rating = 4.9,
    this.tagLabel,
    this.isInCart = false,
    this.cartQuantity = 0,
    required this.onTap,
    required this.onAddToCart,
    this.onBuyNow,
    this.onViewCart,
    this.onIncrementQuantity,
    this.onDecrementQuantity,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _optimisticAdded = false;
  late bool _favoriteState;

  @override
  void initState() {
    super.initState();
    _favoriteState = widget.isFavorite;
  }

  int get discountPercent {
    if (widget.originalPrice != null &&
        widget.originalPrice! > widget.price &&
        widget.originalPrice! > 0) {
      return (((widget.originalPrice! - widget.price) / widget.originalPrice!) *
              100)
          .round();
    }
    return 0;
  }

  String get defaultTag {
    if (widget.tagLabel != null && widget.tagLabel!.isNotEmpty) {
      return widget.tagLabel!;
    }
    final cat = widget.category.toLowerCase();
    if (cat.contains('bach')) return 'DRUGLESS THERAPY';
    if (cat.contains('reiki') || cat.contains('crystal')) return 'REIKI CLEANSED';
    if (cat.contains('aroma') || cat.contains('candle')) return 'SOY WAX • REIKI';
    if (cat.contains('yantra') || cat.contains('brass')) return 'CONSECRATED BRASS';
    if (cat.contains('sound') || cat.contains('singing')) return '7 METALS • SOUND';
    return 'ORGANIC • CHAKRA';
  }

  Color _getBadgeBgColor(String tag) {
    final t = tag.toUpperCase();
    if (t.contains('REIKI')) return const Color(0xFFECFDF5);
    if (t.contains('SOY') || t.contains('AROMA')) return const Color(0xFFF3E8FF);
    if (t.contains('BRASS') || t.contains('CONSECRATED')) return const Color(0xFFFEF3C7);
    if (t.contains('DRUGLESS')) return const Color(0xFFE0F2FE);
    return const Color(0xFFEEF2FF);
  }

  Color _getBadgeTextColor(String tag) {
    final t = tag.toUpperCase();
    if (t.contains('REIKI')) return const Color(0xFF047857);
    if (t.contains('SOY') || t.contains('AROMA')) return const Color(0xFF6E4F9A);
    if (t.contains('BRASS') || t.contains('CONSECRATED')) return const Color(0xFFB45309);
    if (t.contains('DRUGLESS')) return const Color(0xFF0369A1);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isCartActive = widget.isInCart || _optimisticAdded;
    final displayQty = widget.cartQuantity > 0 ? widget.cartQuantity : 1;
    final tagText = defaultTag;
    final badgeBg = _getBadgeBgColor(tagText);
    final badgeText = _getBadgeTextColor(tagText);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCartActive
                ? const Color(0xFF059669)
                : const Color(0xFFE2E8F0),
            width: isCartActive ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isCartActive
                  ? const Color(0x1F059669)
                  : const Color(0x0C000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE CONTAINER WITH ASPECT RATIO, WISHLIST HEART & RATING PILL
            AspectRatio(
              aspectRatio: 1.12,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Stack(
                    children: [
                      Center(
                        child: widget.imageUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: widget.imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.primary),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 44,
                                  color: AppColors.textHint,
                                ),
                              )
                            : const Icon(
                                Icons.shopping_bag_outlined,
                                size: 44,
                                color: AppColors.textHint,
                              ),
                      ),

                      // Brand Emblem Watermark
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Image.asset(
                          AssetPaths.beeBeyondEmblem,
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Wishlist Heart Button (Top Right)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _favoriteState = !_favoriteState;
                            });
                            if (widget.onFavoriteToggle != null) {
                              widget.onFavoriteToggle!();
                            }
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _favoriteState
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _favoriteState
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF64748B),
                              size: 16,
                            ),
                          ),
                        ),
                      ),

                      // Rating Pill Badge (Bottom Left)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.rating}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // CONTENT SECTION
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Tag & Unit Weight Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tagText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: badgeText,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.unitType,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Title
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: const Color(0xFF0F172A),
                        height: 1.22,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Price & Discount Row
                    Row(
                      children: [
                        Text(
                          CurrencyUtils.formatINR(widget.price),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15.0,
                          ),
                        ),
                        if (widget.originalPrice != null &&
                            widget.originalPrice! > widget.price) ...[
                          const SizedBox(width: 5),
                          Text(
                            CurrencyUtils.formatINR(widget.originalPrice!),
                            style: AppTextStyles.labelSmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFF94A3B8),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                        if (discountPercent > 0) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$discountPercent% OFF',
                              style: const TextStyle(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const Spacer(),

                    // ACTION BUTTONS ROW (CART ICON + BUY NOW BUTTON)
                    Row(
                      children: [
                        if (isCartActive) ...[
                          // Quantity Counter Pill in Emerald Green
                          Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: widget.onDecrementQuantity,
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.remove_rounded,
                                        color: Color(0xFF059669), size: 14),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '$displayQty',
                                    style: const TextStyle(
                                      color: Color(0xFF065F46),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: widget.onIncrementQuantity,
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.add_rounded,
                                        color: Color(0xFF059669), size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          // View Cart Shining Button in Emerald Green
                          Expanded(
                            child: ShiningBuyNowButton(
                              label: 'CART',
                              backgroundColor: const Color(0xFF059669),
                              onPressed: () {
                                if (widget.onViewCart != null) {
                                  widget.onViewCart!();
                                } else {
                                  widget.onTap();
                                }
                              },
                            ),
                          ),
                        ] else ...[
                          // Add To Cart Animated Icon Button
                          _AnimatedIconButton(
                            icon: Icons.shopping_cart_outlined,
                            backgroundColor: const Color(0xFFF1F5F9),
                            iconColor: const Color(0xFF334155),
                            onTap: () {
                              setState(() {
                                _optimisticAdded = true;
                              });
                              widget.onAddToCart();
                            },
                            tooltip: 'Add to Cart',
                          ),
                          const SizedBox(width: 5),
                          // Quick Buy Shining Button in Purple
                          Expanded(
                            child: ShiningBuyNowButton(
                              label: 'Buy Now',
                              backgroundColor: const Color(0xFF6E4F9A),
                              onPressed: () {
                                if (widget.onBuyNow != null) {
                                  widget.onBuyNow!();
                                } else {
                                  widget.onTap();
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ANIMATED TACTILE ICON BUTTON WITH BOUNCE RIPPLE FEEDBACK
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String? tooltip;

  const _AnimatedIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
    this.tooltip,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 34,
          height: 32,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(widget.icon, color: widget.iconColor, size: 17),
          ),
        ),
      ),
    );
  }
}

/// COMPACT SHINING BUY NOW BUTTON WITH PERIODIC LIGHT BEAM
class ShiningBuyNowButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final Color backgroundColor;

  const ShiningBuyNowButton({
    super.key,
    required this.onPressed,
    this.label = 'Buy Now',
    this.backgroundColor = const Color(0xFF6E4F9A),
  });

  @override
  State<ShiningBuyNowButton> createState() => _ShiningBuyNowButtonState();
}

class _ShiningBuyNowButtonState extends State<ShiningBuyNowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shineAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _shineAnimation = Tween<double>(begin: -1.2, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _startShineLoop();
  }

  void _startShineLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        await _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: 0.35),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 14, color: Colors.amberAccent),
                      const SizedBox(width: 2),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Periodic Shining Glint Light Beam
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shineAnimation,
                      builder: (context, child) {
                        return FractionalTranslation(
                          translation: Offset(_shineAnimation.value, 0),
                          child: Transform.rotate(
                            angle: 0.35,
                            child: Container(
                              width: 18,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.95),
                                    Colors.amberAccent.withValues(alpha: 0.8),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.35, 0.65, 1.0],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
}
