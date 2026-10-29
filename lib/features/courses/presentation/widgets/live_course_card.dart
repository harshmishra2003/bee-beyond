import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/live_pulsing_badge.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../domain/entities/course_entity.dart';

class LiveCourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;
  final VoidCallback onJoinNow;

  const LiveCourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onJoinNow,
  });

  @override
  Widget build(BuildContext context) {
    final batchStartStr = course.batchStartDate != null
        ? DateFormat('MMM d').format(course.batchStartDate!)
        : 'Soon';

    return Container(
      // SLEEK OVAL-RECTANGULAR DARK GRADIENT FRAME (SURROUNDING BORDER EFFECT)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F0C20),
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF818CF8).withAlpha(180),
          width: 1.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x301E1B4B),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. THUMBNAIL COVER FRAME WITH LIVE BADGE & EMBLEM
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    height: 98,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        course.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: course.imageUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorWidget: (context, url, error) =>
                                    _buildDefaultBanner(),
                                placeholder: (context, url) =>
                                    _buildDefaultBanner(),
                              )
                            : _buildDefaultBanner(),

                        // Top Dark Gradient Overlay for Contrast
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black54,
                                  Colors.transparent,
                                  Colors.black45,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                        // Live Pulsing Badge (Top-Left)
                        const Positioned(
                          top: 6,
                          left: 6,
                          child: LivePulsingBadge(
                            fontSize: 8.5,
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2.5),
                          ),
                        ),

                        // Transparent Emblem Badge (Top-Right)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 22,
                            height: 22,
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(50),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white70, width: 1.0),
                            ),
                            child: Image.asset(
                              AssetPaths.beeBeyondEmblem,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.spa_rounded,
                                      size: 12, color: Colors.amberAccent),
                            ),
                          ),
                        ),

                        // Bottom Batch Info Chips (Overlaid Bottom-Left)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF312E81).withAlpha(220),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer_outlined,
                                        color: Colors.amberAccent, size: 10),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${course.courseDurationDays} Days',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withAlpha(220),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_available_rounded,
                                        color: Colors.white, size: 10),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Starts $batchStartStr',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. COURSE DETAILS & SHINING JOIN NOW BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              course.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Text(
                            CurrencyUtils.formatINR(course.price),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // SHINING 3D JOIN NOW BUTTON
                      ThreeDButton(
                        width: double.infinity,
                        text: 'JOIN NOW ▶',
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        icon: const Icon(Icons.videocam_rounded,
                            color: Colors.amberAccent, size: 13),
                        onPressed: onJoinNow,
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

  Widget _buildDefaultBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF312E81),
            Color(0xFF4338CA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.videocam_rounded, color: Colors.white24, size: 36),
      ),
    );
  }
}
