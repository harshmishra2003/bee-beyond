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
  final bool isInCart;
  final int cartQuantity;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback? onBuyNow;
  final VoidCallback? onIncrementQuantity;
  final VoidCallback? onDecrementQuantity;

  const ProductCard({
    super.key,
    required this.title,
    this.category = 'STORE',
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.unitType = '500 g',
    this.isInCart = false,
    this.cartQuantity = 0,
    required this.onTap,
    required this.onAddToCart,
    this.onBuyNow,
    this.onIncrementQuantity,
    this.onDecrementQuantity,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _optimisticAdded = false;

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

  Color _getAccentFrameColor(String text) {
    const frameColors = [
      Color(0xFF6366F1), // Royal Indigo
      Color(0xFF10B981), // Emerald Green
      Color(0xFFF59E0B), // Amber Gold
      Color(0xFFF43F5E), // Rose Pink
      Color(0xFF06B6D4), // Cyan Sapphire
      Color(0xFF8B5CF6), // Violet Amethyst
    ];
    final hash = text.hashCode.abs();
    return frameColors[hash % frameColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final frameColor = _getAccentFrameColor(widget.title);
    final isCartActive = widget.isInCart || _optimisticAdded;
    final displayQty = widget.cartQuantity > 0 ? widget.cartQuantity : 1;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCartActive
                ? const Color(0xFF059669)
                : frameColor.withValues(alpha: 0.5),
            width: isCartActive ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isCartActive
                  ? const Color(0x20059669)
                  : frameColor.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FULLY VISIBLE PRODUCT THUMBNAIL (NO CROP) WITH EMBLEM & BADGES
            Container(
              height: 125,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isCartActive
                    ? const Color(0xFFECFDF5)
                    : frameColor.withValues(alpha: 0.05),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Center(
                      child: widget.imageUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: widget.imageUrl,
                              height: 125,
                              width: double.infinity,
                              fit: BoxFit.contain, // FULL IMAGE VISIBLE
                              placeholder: (context, url) => const SizedBox(
                                height: 125,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.shopping_bag_outlined,
                                size: 40,
                                color: AppColors.textHint,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              size: 40,
                              color: AppColors.textHint,
                            ),
                    ),

                    // Top Right Brand Emblem Logo Watermark
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Image.asset(
                        AssetPaths.beeBeyondEmblem,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Rating Pill
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: frameColor.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '4.5',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.star_rounded,
                                size: 10, color: Color(0xFF059669)),
                          ],
                        ),
                      ),
                    ),

                    // In Cart Active Status Badge
                    if (isCartActive)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Text(
                            'IN CART ✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag & Unit Weight Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: frameColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          widget.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: frameColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          widget.unitType,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  SizedBox(
                    height: 32,
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        height: 1.22,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Discount Percentage Badge
                  if (discountPercent > 0)
                    Text(
                      '$discountPercent% OFF',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF059669), // Green discount tag
                      ),
                    ),

                  const SizedBox(height: 2),

                  Row(
                    children: [
                      Text(
                        CurrencyUtils.formatINR(widget.price),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      if (widget.originalPrice != null &&
                          widget.originalPrice! > widget.price) ...[
                        const SizedBox(width: 5),
                        Text(
                          CurrencyUtils.formatINR(widget.originalPrice!),
                          style: AppTextStyles.labelSmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textHint,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // SMART ANIMATED COMPACT ICON ACTIONS ROW
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
                                      color: Color(0xFF059669), size: 15),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
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
                                      color: Color(0xFF059669), size: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // View Cart Shining Button in Emerald Green
                        Expanded(
                          child: ShiningBuyNowButton(
                            label: 'CART',
                            backgroundColor: const Color(0xFF059669),
                            onPressed: widget.onBuyNow ?? widget.onTap,
                          ),
                        ),
                      ] else ...[
                        // Add To Cart Animated Icon Button
                        _AnimatedIconButton(
                          icon: Icons.add_shopping_cart_rounded,
                          backgroundColor: const Color(0xFFEEF2FF),
                          iconColor: AppColors.primary,
                          onTap: () {
                            setState(() {
                              _optimisticAdded = true;
                            });
                            widget.onAddToCart();
                          },
                          tooltip: 'Add to Cart',
                        ),
                        const SizedBox(width: 6),
                        // Quick Buy Shining Button with Light Beam Glint
                        Expanded(
                          child: ShiningBuyNowButton(
                            label: 'BUY NOW',
                            backgroundColor: AppColors.primary,
                            onPressed: () {
                              setState(() {
                                _optimisticAdded = true;
                              });
                              if (widget.onBuyNow != null) {
                                widget.onBuyNow!();
                              } else {
                                widget.onAddToCart();
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
          ],
        ),
      ),
    );
  }
}

/// ANIMATED TACTILE ICON BUTTON WITH BOUNCE RIPPLE FEEDBACK
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String? tooltip;

  const _AnimatedIconButton({
    required this.icon,
    this.label,
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
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 15),
              if (widget.label != null) ...[
                const SizedBox(width: 4),
                Text(
                  widget.label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
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
    this.label = 'BUY NOW',
    this.backgroundColor = AppColors.primary,
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
      await Future.delayed(const Duration(milliseconds: 2000));
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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flash_on_rounded,
                          size: 13, color: Colors.amberAccent),
                      const SizedBox(width: 3),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
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
