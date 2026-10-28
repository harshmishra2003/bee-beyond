import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/banner_entity.dart';

class HomeBannerSlider extends StatefulWidget {
  final List<BannerEntity> banners;
  final Function(BannerEntity)? onBannerTap;

  const HomeBannerSlider({
    super.key,
    required this.banners,
    this.onBannerTap,
  });

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  Timer? _userPauseTimer;
  int _currentIndex = 0;
  bool _isForward = true;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 3200), (timer) {
      if (!mounted || !_pageController.hasClients || _isUserInteracting || widget.banners.length <= 1) return;

      int nextPage;
      if (_isForward) {
        if (_currentIndex < widget.banners.length - 1) {
          nextPage = _currentIndex + 1;
        } else {
          _isForward = false;
          nextPage = _currentIndex - 1;
        }
      } else {
        if (_currentIndex > 0) {
          nextPage = _currentIndex - 1;
        } else {
          _isForward = true;
          nextPage = _currentIndex + 1;
        }
      }

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _handleUserInteraction() {
    setState(() => _isUserInteracting = true);
    _userPauseTimer?.cancel();
    _userPauseTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _isUserInteracting = false);
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _userPauseTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBannerImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fill, // Full-bleed edge-to-edge fit to card with zero side gaps or margins
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.primary,
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 36),
          ),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fill, // Full-bleed edge-to-edge fit to card with zero side gaps or margins
        alignment: Alignment.center,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.primary,
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 36),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isFoldableOrTablet = screenWidth > 600;

        final double targetCardWidth = isFoldableOrTablet
            ? screenWidth * 0.82
            : screenWidth * 0.92;

        // Calculate card height perfectly proportioned to poster aspect ratio (~2.05:1)
        final double bannerHeight = (targetCardWidth / 2.05).clamp(150.0, 260.0);

        final double targetViewport = isFoldableOrTablet ? 0.82 : 0.92;

        if (_pageController.viewportFraction != targetViewport) {
          final oldIndex = _currentIndex;
          _pageController.dispose();
          _pageController = PageController(
            initialPage: oldIndex,
            viewportFraction: targetViewport,
          );
        }

        return Column(
          children: [
            SizedBox(
              height: bannerHeight,
              child: Listener(
                onPointerDown: (_) => _handleUserInteraction(),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.banners.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final banner = widget.banners[index];
                    return _buildBannerCard(banner, isFoldableOrTablet);
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Animated Page Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == index ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? AppColors.primary : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBannerCard(BannerEntity banner, bool isFoldableOrTablet) {
    return GestureDetector(
      onTap: () => widget.onBannerTap?.call(banner),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isFoldableOrTablet ? 10 : 6,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x224B489B),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Banner Poster Image (Fit to Card - Edge to Edge)
              Positioned.fill(
                child: _buildBannerImage(banner.imageUrl),
              ),

              // Light Gradient Overlay for subtle readability without blocking poster graphics
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Top Promotional Badge
              Positioned(
                top: 10,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF524FA1), Color(0xFF383577)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38, width: 0.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.campaign, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'OFFICIAL POSTER',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontSize: 9.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Title & Arrow CTA overlay
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        banner.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 0.8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
