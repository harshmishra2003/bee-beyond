import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../../domain/entities/workshop_item.dart';
import '../providers/workshop_provider.dart';

class WorkshopDetailScreen extends ConsumerWidget {
  final String workshopId;
  final WorkshopItem? initialItem;

  const WorkshopDetailScreen({
    super.key,
    required this.workshopId,
    this.initialItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workshopDetailProvider(workshopId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: initialItem?.title.isNotEmpty == true
            ? initialItem!.title
            : 'Masterclass Details',
      ),
      body: detailAsync.when(
        data: (item) {
          final effectiveItem = item ?? initialItem;
          if (effectiveItem == null) {
            return _buildNotFoundState(context);
          }
          return _buildDetailContent(context, effectiveItem);
        },
        loading: () {
          if (initialItem != null) {
            return _buildDetailContent(context, initialItem!);
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
        error: (err, stack) {
          if (initialItem != null) {
            return _buildDetailContent(context, initialItem!);
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load masterclass details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(workshopDetailProvider(workshopId)),
                    child: const Text('Retry Loading'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, WorkshopItem item) {
    final takeaways = _getEffectiveTakeaways(item);
    final schedule = item.upcomingDates.isNotEmpty
        ? item.upcomingDates
        : [item.isLive ? 'Live Stream (Weekend Batch - 10:00 AM IST)' : 'Instant On-Demand HD Access'];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO COVER IMAGE BANNER
                Stack(
                  children: [
                    item.thumbnailUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: item.thumbnailUrl,
                            height: 230,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 230,
                              color: const Color(0xFF1E1B4B),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 230,
                              color: const Color(0xFF1E1B4B),
                              child: const Icon(Icons.workspace_premium_rounded, size: 64, color: Colors.amber),
                            ),
                          )
                        : Container(
                            height: 230,
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
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // BADGE OVERLAY
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: item.categoryColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          item.categoryBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),

                    // RATING OVERLAY
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${item.rating}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // VIDEO PREVIEW LAUNCHER BUTTON
                    if (item.videoUrl.isNotEmpty)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(item.videoUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Watch Video Preview',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                  ],
                ),

                // 2. MAIN HEADER INFO
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // QUICK HIGHLIGHT KPI BAR
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildKpiItem(Icons.access_time_rounded, item.duration, 'Duration'),
                            _buildKpiDivider(),
                            _buildKpiItem(Icons.groups_rounded, '${item.bookedSeats > 0 ? item.bookedSeats : item.views}+', 'Enrolled'),
                            _buildKpiDivider(),
                            _buildKpiItem(Icons.event_seat_rounded, '${item.availableSeats}', 'Seats Left'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // MENTOR PROFILE CARD
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.instructor,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified_rounded, color: Color(0xFF0288D1), size: 16),
                                    ],
                                  ),
                                  Text(
                                    item.lineage,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'VERIFIED MENTOR',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 3. OVERVIEW & DESCRIPTION
                      const Text(
                        'MASTERCLASS OVERVIEW',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          item.description.isNotEmpty
                              ? item.description
                              : 'Join this transformative accredited masterclass offering interactive practical training, deep clinical insights, and step-by-step guidance under revered mentors.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 4. LEARNING OUTCOMES & TAKEAWAYS
                      const Text(
                        'WHAT YOU WILL LEARN & RECEIVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          children: List.generate(takeaways.length, (idx) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDCFCE7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      takeaways[idx],
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 5. MASTERCLASS CURRICULUM AGENDA
                      const Text(
                        'CURRICULUM & MODULE AGENDA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildAgendaCard(
                        stepNumber: '01',
                        title: 'Sacred Foundations & Diagnostic Framework',
                        subtitle: 'Theoretical introduction, lineage origins, and clinical evaluation methodology.',
                      ),
                      _buildAgendaCard(
                        stepNumber: '02',
                        title: 'Practical Hands-on Demonstrations',
                        subtitle: 'Step-by-step guided practice, sound bowl/herbal/energy alignment protocols.',
                      ),
                      _buildAgendaCard(
                        stepNumber: '03',
                        title: 'Case Studies & Real-World Applications',
                        subtitle: 'Live walkthroughs of clinical case studies, remedy selections, and corrections.',
                      ),
                      _buildAgendaCard(
                        stepNumber: '04',
                        title: 'Q&A, Certification & Integration Routine',
                        subtitle: 'Interactive doubt resolution, daily integration schedule, and certificate download.',
                      ),

                      const SizedBox(height: 22),

                      // 6. DELIVERABLES & PERKS
                      const Text(
                        'INCLUDED DELIVERABLES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildDeliverableChip(Icons.verified_rounded, 'ISO Accredited Certificate', const Color(0xFF059669)),
                      _buildDeliverableChip(Icons.video_library_rounded, 'Lifetime HD Recording Access', const Color(0xFF6366F1)),
                      _buildDeliverableChip(Icons.picture_as_pdf_rounded, 'Downloadable PDF Handbooks', const Color(0xFFEC4899)),
                      _buildDeliverableChip(Icons.forum_rounded, 'Private Mentor Q&A Access', const Color(0xFFD97706)),

                      const SizedBox(height: 22),

                      // 7. SCHEDULE & TIMINGS
                      const Text(
                        'SCHEDULE & SESSION TIMINGS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children: schedule.map((sch) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFC7D2FE)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sch,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.isLive ? 'LIVE BATCH' : 'ON DEMAND',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // STICKY BOTTOM ACTION BAR
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
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      CurrencyUtils.formatINR(item.finalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      RoutePaths.workshopBooking,
                      extra: item.toJson(),
                    );
                  },
                  icon: Icon(
                    item.isRegistered
                        ? Icons.check_circle_rounded
                        : (item.isFull ? Icons.event_seat_rounded : Icons.confirmation_number_rounded),
                    size: 18,
                  ),
                  label: Text(
                    item.isRegistered
                        ? '✓ Seat Confirmed'
                        : (item.isFull ? 'Capacity Full' : 'Book Masterclass'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isRegistered
                        ? const Color(0xFF10B981)
                        : (item.isFull ? const Color(0xFF94A3B8) : AppColors.primary),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildKpiDivider() {
    return Container(
      width: 1,
      height: 24,
      color: const Color(0xFFCBD5E1),
    );
  }

  Widget _buildAgendaCard({
    required String stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stepNumber,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverableChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getEffectiveTakeaways(WorkshopItem item) {
    if (item.takeaways.isNotEmpty) return item.takeaways;

    final cat = item.category.toLowerCase();
    if (cat.contains('sound') || cat.contains('audio')) {
      return const [
        '528Hz Solfeggio acoustic frequency alignment & chakra tuning protocols',
        'Singing bowl vibration therapy & harmonic resonance techniques',
        'Deep theta-wave meditation state transition practice',
        'Official accredited completion certificate & digital study handbook',
      ];
    } else if (cat.contains('vastu') || cat.contains('energy')) {
      return const [
        'Nadi & Marma directional energy grid evaluation methods',
        'Elemental balancing without structural demolition or alterations',
        'Pyramid & crystal directional alignment protocols',
        'Practical residential & commercial vastu case study walkthroughs',
      ];
    } else if (cat.contains('ayurveda') || cat.contains('wellness')) {
      return const [
        'Tridosha (Vata, Pitta, Kapha) constitution & pulse diagnosis',
        'Organic herbal compounding & customary kadha brewing',
        'Daily Dinacharya routines for mental clarity & immunity',
        'Comprehensive herbal reference manual & diagnostic charts',
      ];
    } else {
      return const [
        'Subconscious emotional reprogramming & mental clarity methods',
        'Pranayama breathwork routines for stress & anxiety dissolution',
        'Daily 10-minute mindfulness & focus integration protocol',
        'Accredited certificate & exclusive mentor Q&A access',
      ];
    }
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text(
            'Masterclass Not Found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
