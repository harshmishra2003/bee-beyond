import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/category_entity.dart';

class _FrameTheme {
  final Color bg;
  final Color border;
  final Color glow;

  const _FrameTheme({required this.bg, required this.border, required this.glow});
}

const List<_FrameTheme> _pastelFrames = [
  _FrameTheme(
    bg: Color(0xFFF2F9F5),
    border: Color(0xFFA2E0C0),
    glow: Color(0x202E7D5B),
  ),
  _FrameTheme(
    bg: Color(0xFFFFF9EE),
    border: Color(0xFFFFDB94),
    glow: Color(0x20D4A373),
  ),
  _FrameTheme(
    bg: Color(0xFFF8F2FC),
    border: Color(0xFFDAA8F5),
    glow: Color(0x209C27B0),
  ),
  _FrameTheme(
    bg: Color(0xFFFFF2F4),
    border: Color(0xFFFFB2BF),
    glow: Color(0x20E91E63),
  ),
  _FrameTheme(
    bg: Color(0xFFEFF9FA),
    border: Color(0xFF91DDE3),
    glow: Color(0x2000ACC1),
  ),
  _FrameTheme(
    bg: Color(0xFFFFF6F0),
    border: Color(0xFFFFC5A1),
    glow: Color(0x20FF9800),
  ),
];

class CategoryCarousel extends StatefulWidget {
  final List<CategoryEntity> categories;
  final Function(CategoryEntity) onCategorySelected;

  const CategoryCarousel({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  bool _isMovingForward = true;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted || !_scrollController.hasClients || _isUserInteracting) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (maxScroll <= 0) return;

      double nextScroll;
      const double step = 0.8;

      if (_isMovingForward) {
        nextScroll = currentScroll + step;
        if (nextScroll >= maxScroll) {
          nextScroll = maxScroll;
          _isMovingForward = false;
        }
      } else {
        nextScroll = currentScroll - step;
        if (nextScroll <= 0) {
          nextScroll = 0;
          _isMovingForward = true;
        }
      }

      _scrollController.jumpTo(nextScroll);
    });
  }

  void _handlePointerDown() {
    setState(() => _isUserInteracting = true);
    _resumeTimer?.cancel();
  }

  void _handlePointerUp() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isUserInteracting = false);
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'spa':
        return Icons.spa_outlined;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'self_improvement':
        return Icons.self_improvement_outlined;
      case 'healing':
        return Icons.healing_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'edit_note':
        return Icons.edit_note_outlined;
      case 'diversity_1':
        return Icons.diversity_1_outlined;
      case 'fingerprint':
        return Icons.fingerprint_outlined;
      case 'auto_awesome':
        return Icons.auto_awesome_outlined;
      case 'brightness_high':
        return Icons.brightness_high_outlined;
      case 'temple_buddhist':
        return Icons.temple_buddhist_outlined;
      case 'balance':
        return Icons.balance_outlined;
      case 'filter_vintage':
        return Icons.filter_vintage_outlined;
      case 'stars':
        return Icons.stars_outlined;
      case 'bubble_chart':
        return Icons.bubble_chart_outlined;
      case 'emoji_events':
        return Icons.emoji_events_outlined;
      case 'local_florist':
        return Icons.local_florist_outlined;
      case 'home_work':
        return Icons.home_work_outlined;
      default:
        return Icons.spa_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 128,
      child: Listener(
        onPointerDown: (_) => _handlePointerDown(),
        onPointerUp: (_) => _handlePointerUp(),
        onPointerCancel: (_) => _handlePointerUp(),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            final cat = widget.categories[index];
            final frame = _pastelFrames[index % _pastelFrames.length];

            return GestureDetector(
              onTap: () => widget.onCategorySelected(cat),
              child: Container(
                width: 88,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    // Circular Light-Colored Frame
                    Container(
                      width: 74,
                      height: 74,
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: frame.bg,
                        border: Border.all(color: frame.border, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: frame.glow,
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _CategoryCircularImage(
                          imageUrl: cat.imageUrl,
                          fallbackIcon: _getCategoryIcon(cat.icon),
                          fallbackColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    // Category Name Text
                    Text(
                      cat.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCircularImage extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const _CategoryCircularImage({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('assets/')) {
        return Image.asset(
          imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
        );
      } else if (imageUrl!.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.white24,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildFallbackIcon(),
        );
      }
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Icon(fallbackIcon, color: fallbackColor, size: 28),
      ),
    );
  }
}
