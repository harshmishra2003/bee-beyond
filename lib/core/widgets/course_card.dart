import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/asset_paths.dart';
import '../theme/app_colors.dart';
import '../utils/currency_utils.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String category;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String duration;
  final double rating;
  final VoidCallback onTap;
  final VoidCallback? onJoinGroup;

  const CourseCard({
    super.key,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.duration,
    required this.rating,
    required this.onTap,
    this.onJoinGroup,
  });

  Widget _buildPlaceholder() {
    return Container(
      width: 115,
      height: 110,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_rounded, size: 32, color: AppColors.primary),
          SizedBox(height: 4),
          Text(
            'Bee Beeyond',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: 115,
        height: 110,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: 115,
        height: 110,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: 115,
          height: 110,
          color: const Color(0xFFF1F5F9),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final computedOriginalPrice = originalPrice ?? (price > 0 ? price * 1.3 : null);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C4B489B),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDE: FULLY VISIBLE IMAGE THUMBNAIL (NO CROPPING / ZERO CUT)
                Container(
                  width: 115,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: _buildCourseImage(imageUrl),
                        ),
                      ),
                      // Top Right Brand Emblem Badge
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 3),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AssetPaths.beeBeyondImage2,
                              width: 16,
                              height: 16,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // RIGHT SIDE: EXPANDED DETAILS (AMAZON / FLIPKART STYLE)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Tag & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          height: 1.22,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Duration & Modules Row
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFF059669)),
                          const SizedBox(width: 3),
                          const Text(
                            'Certified',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Price & Action Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyUtils.formatINR(price),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              if (computedOriginalPrice != null)
                                Text(
                                  CurrencyUtils.formatINR(computedOriginalPrice),
                                  style: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),

                          if (onJoinGroup != null)
                            InkWell(
                              onTap: onJoinGroup,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x2025D366), blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.groups_rounded, size: 13, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Join Group',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
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
