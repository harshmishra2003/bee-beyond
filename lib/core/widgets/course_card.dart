import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/asset_paths.dart';
import '../theme/app_colors.dart';
import '../utils/currency_utils.dart';
import 'shining_join_group_button.dart';

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
  final DateTime? createdAt;
  final bool isNew;
  final bool isEnrolled;

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
    this.createdAt,
    this.isNew = false,
    this.isEnrolled = false,
  });

  bool get _shouldShowNewBadge {
    if (isNew) return true;
    if (createdAt != null) {
      final diffInHours = DateTime.now().difference(createdAt!).inHours;
      return diffInHours >= 0 && diffInHours <= 48; // Disappears after 48 hours (2 days)
    }
    return false;
  }

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
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: double.infinity,
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
        color: isEnrolled ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEnrolled ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
          width: isEnrolled ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isEnrolled ? const Color(0x15059669) : const Color(0x0C4B489B),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                // LEFT SIDE: FULLY VISIBLE IMAGE THUMBNAIL WITH NEW/ENROLLED BADGE OVERLAY
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
                        child: Image.asset(
                          AssetPaths.beeBeyondEmblem,
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Top Left "NEW" Lottie Animated Badge (Visible for 2 days from creation)
                      if (_shouldShowNewBadge && !isEnrolled)
                        Positioned(
                          top: 2,
                          left: 2,
                          child: SizedBox(
                            width: 38,
                            height: 24,
                            child: Lottie.asset(
                              AssetPaths.lottieNewBadge,
                              fit: BoxFit.contain,
                              repeat: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // RIGHT SIDE: EXPANDED DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Tag & Rating / Enrolled Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isEnrolled ? const Color(0xFF059669) : AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isEnrolled ? 'ENROLLED ✓' : category.toUpperCase(),
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
                        style: TextStyle(
                          color: isEnrolled ? const Color(0xFF065F46) : AppColors.textPrimary,
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
                                isEnrolled ? 'ENROLLED' : CurrencyUtils.formatINR(price),
                                style: TextStyle(
                                  color: isEnrolled ? const Color(0xFF059669) : AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: isEnrolled ? 13 : 15,
                                ),
                              ),
                              if (!isEnrolled && computedOriginalPrice != null)
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
                            ShiningJoinGroupButton(
                              onPressed: onJoinGroup!,
                              text: isEnrolled ? 'Group Chat' : 'Join Group',
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
