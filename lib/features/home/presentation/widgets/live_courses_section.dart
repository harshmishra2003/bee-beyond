import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/shining_view_all_button.dart';
import '../../../../routing/route_paths.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../courses/presentation/widgets/live_course_carousel.dart';
import '../../../courses/presentation/widgets/live_course_info_dialog.dart';

class LiveCoursesSection extends ConsumerWidget {
  final VoidCallback onViewAllTap;
  final Function(String courseId) onCourseTap;

  const LiveCoursesSection({
    super.key,
    required this.onViewAllTap,
    required this.onCourseTap,
  });

  void _handleJoinNowTap(BuildContext context, CourseEntity course) {
    LiveCourseInfoDialog.show(
      context,
      course: course,
      onProceedToEnrollment: () {
        context.push('${RoutePaths.courseEnrollment}?id=${course.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(allCoursesProvider);

    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) return const SizedBox.shrink();

        // Generate Live Courses for the Dedicated Live Section
        final List<CourseEntity> liveCourses = courses.map((c) {
          return CourseEntity(
            id: c.id,
            title: c.title,
            description: c.description,
            category: c.category,
            subCategory: c.subCategory,
            imageUrl: c.imageUrl,
            trailerUrl: c.trailerUrl,
            price: c.price,
            duration: c.duration,
            rating: c.rating,
            modulesCount: c.modulesCount,
            learnings: c.learnings,
            modulesList: c.modulesList,
            createdAt: c.createdAt,
            isLive: true,
            batchStartDate:
                c.batchStartDate ?? DateTime.now().add(const Duration(days: 2)),
            batchEndDate:
                c.batchEndDate ?? DateTime.now().add(const Duration(days: 17)),
            registrationDeadline: c.registrationDeadline ??
                DateTime.now().add(const Duration(hours: 18)),
            courseDurationDays:
                c.courseDurationDays > 0 ? c.courseDurationDays : 15,
            meetingLink: c.meetingLink.isNotEmpty
                ? c.meetingLink
                : 'https://zoom.us/j/1234567890',
            outcomes: c.learnings,
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DEDICATED LIVE COURSES RIBBON HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E1B4B),
                    Color(0xFF312E81),
                    Color(0xFF4338CA),
                    Color(0xFF312E81),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x281E1B4B),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4.5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.redAccent, width: 1),
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: Colors.redAccent,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIVE COURSES & BATCHES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          'Interactive live masterclasses with certified doctors',
                          style: TextStyle(
                            color: Color(0xFFC7D2FE),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ShiningViewAllButton(onPressed: onViewAllTap),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 3D SCROLLING SLIDING LIVE COURSE CAROUSEL
            LiveCourseCarousel(
              liveCourses: liveCourses,
              onCourseTap: (c) => onCourseTap(c.id),
              onJoinNowTap: (c) => _handleJoinNowTap(context, c),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
