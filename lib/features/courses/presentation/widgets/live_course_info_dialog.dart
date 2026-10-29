import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/live_pulsing_badge.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../domain/entities/course_entity.dart';

class LiveCourseInfoDialog extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onProceedToEnrollment;

  const LiveCourseInfoDialog({
    super.key,
    required this.course,
    required this.onProceedToEnrollment,
  });

  static void show(
    BuildContext context, {
    required CourseEntity course,
    required VoidCallback onProceedToEnrollment,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => LiveCourseInfoDialog(
        course: course,
        onProceedToEnrollment: () {
          Navigator.pop(ctx);
          onProceedToEnrollment();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batchStartStr = course.batchStartDate != null
        ? DateFormat('EEEE, MMM d, yyyy').format(course.batchStartDate!)
        : 'To Be Announced';

    final batchEndStr = course.batchEndDate != null
        ? DateFormat('EEEE, MMM d, yyyy').format(course.batchEndDate!)
        : 'Continuous Access';

    final deadlineStr = course.registrationDeadline != null
        ? DateFormat('MMM d, yyyy • hh:mm a').format(course.registrationDeadline!)
        : 'Closing Soon';

    final outcomes = course.learnings.isNotEmpty
        ? course.learnings
        : [
            '100% Interactive Live Practitioner Masterclass',
            'Full Access to Recorded Modules & PDF Handbooks',
            'Direct Q&A Sessions with Certified Holistic Experts',
            'Official Certificate of Completion Included',
          ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. DIALOG HEADER WITH LIVE BADGE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E1B4B),
                      Color(0xFF312E81),
                      Color(0xFF4338CA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const LivePulsingBadge(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white70, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Price: ${CurrencyUtils.formatINR(course.price)} • Live Interactive Batch',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. BATCH TIMELINE & DURATION INFO CARDS
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BATCH SCHEDULE & TIMELINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildInfoTile(
                      icon: Icons.timer_outlined,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: AppColors.primary,
                      title: 'Course Duration',
                      value: '${course.courseDurationDays} Days Masterclass Batch',
                    ),
                    const SizedBox(height: 8),

                    _buildInfoTile(
                      icon: Icons.event_available_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                      title: 'Batch Schedule',
                      value: '$batchStartStr\nto $batchEndStr',
                    ),
                    const SizedBox(height: 8),

                    _buildInfoTile(
                      icon: Icons.access_time_filled_rounded,
                      iconBg: const Color(0xFFFEF2F2),
                      iconColor: const Color(0xFFEF4444),
                      title: 'Registration Cutoff Deadline',
                      value: deadlineStr,
                      isUrgent: true,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'WHAT YOU WILL LEARN & OUTCOMES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...outcomes.take(4).map(
                          (outcome) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Color(0xFF10B981), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    outcome,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                    const SizedBox(height: 18),

                    // CTA PROCEED BUTTON
                    ThreeDButton(
                      width: double.infinity,
                      text: 'PROCEED TO ENROLLMENT ▶',
                      fontSize: 13.5,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      icon: const Icon(Icons.lock_rounded,
                          color: Colors.amberAccent, size: 18),
                      onPressed: onProceedToEnrollment,
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

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconBg.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withAlpha(60), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUrgent ? const Color(0xFFEF4444) : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isUrgent ? const Color(0xFFB91C1C) : AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
