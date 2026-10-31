import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../../domain/entities/workshop_item.dart';
import '../providers/workshop_provider.dart';

class WorkshopDetailScreen extends ConsumerWidget {
  final String workshopId;

  const WorkshopDetailScreen({
    super.key,
    required this.workshopId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workshopDetailProvider(workshopId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Masterclass Details'),
      body: detailAsync.when(
        data: (item) {
          if (item == null) {
            return _buildNotFoundState(context);
          }
          return _buildDetailContent(context, item);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, WorkshopItem item) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // COVER IMAGE BANNER
                Stack(
                  children: [
                    item.thumbnailUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: item.thumbnailUrl,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 220,
                              color: const Color(0xFF1E1B4B),
                              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 220,
                              color: const Color(0xFF1E1B4B),
                              child: const Icon(Icons.workspace_premium_rounded, size: 64, color: Colors.amber),
                            ),
                          )
                        : Container(
                            height: 220,
                            color: const Color(0xFF1E1B4B),
                            child: const Icon(Icons.workspace_premium_rounded, size: 64, color: Colors.amber),
                          ),

                    // GRADIENT OVERLAY
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // BADGES
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.categoryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.categoryBadge,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    if (item.videoUrl.isNotEmpty)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(item.videoUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                          label: Text(
                            'Watch Preview',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                  ],
                ),

                // TITLE & INSTRUCTOR INFO
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${item.rating} Rating',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.remove_red_eye_rounded, color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${item.views} Enrolled',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // INSTRUCTOR CARD
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle, width: 1),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.instructor,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    item.lineage,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // DESCRIPTION OVERVIEW
                      Text(
                        'Workshop Overview',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // KEY TAKEAWAYS
                      if (item.takeaways.isNotEmpty) ...[
                        Text(
                          'What You Will Learn & Receive',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...item.takeaways.map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // UPCOMING DATES / STREAM FORMAT
                      if (item.upcomingDates.isNotEmpty) ...[
                        Text(
                          'Schedule & Format',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...item.upcomingDates.map(
                          (d) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  d,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // STICKY BOTTOM BAR
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.discount > 0)
                      Text(
                        CurrencyUtils.formatINR(item.basePrice),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      CurrencyUtils.formatINR(item.finalPrice),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push(
                      RoutePaths.workshopBooking,
                      extra: item.toJson(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Book Masterclass',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            'Masterclass Not Found',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
