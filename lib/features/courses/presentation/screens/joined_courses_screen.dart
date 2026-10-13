import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../../domain/entities/joined_course_entity.dart';
import '../providers/course_provider.dart';

class JoinedCoursesScreen extends ConsumerStatefulWidget {
  const JoinedCoursesScreen({super.key});

  @override
  ConsumerState<JoinedCoursesScreen> createState() => _JoinedCoursesScreenState();
}

class _JoinedCoursesScreenState extends ConsumerState<JoinedCoursesScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'In Progress', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final joinedAsync = ref.watch(joinedCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'My Joined Courses'),
      body: joinedAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return _buildEmptyState(context);
          }

          final inProgressCount = courses.where((c) => c.progressPercentage < 100).length;
          final completedCount = courses.where((c) => c.progressPercentage >= 100).length;

          // Calculate average progress
          final totalProgress = courses.fold<double>(0, (sum, c) => sum + c.progressPercentage);
          final avgProgress = courses.isNotEmpty ? (totalProgress / courses.length) : 0.0;

          final filteredCourses = courses.where((c) {
            if (_selectedFilter == 'In Progress') {
              return c.progressPercentage < 100;
            } else if (_selectedFilter == 'Completed') {
              return c.progressPercentage >= 100;
            }
            return true;
          }).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // TOP OVERVIEW ANALYTICS CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildOverviewBanner(
                    totalCourses: courses.length,
                    inProgressCount: inProgressCount,
                    completedCount: completedCount,
                    avgProgress: avgProgress,
                  ),
                ),

                const SizedBox(height: 20),

                // FILTER CHIPS
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;

                      int count = courses.length;
                      if (filter == 'In Progress') count = inProgressCount;
                      if (filter == 'Completed') count = completedCount;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(60),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            '$filter ($count)',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // SECTION HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_selectedFilter Courses (${filteredCourses.length})',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // JOINED COURSES LIST
                if (filteredCourses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No courses found in $_selectedFilter category.',
                        style: const TextStyle(color: AppColors.textHint, fontSize: 14),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredCourses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final c = filteredCourses[index];
                      return _buildJoinedCourseCard(context, c);
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, st) => Center(child: Text('Error loading courses: $e', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  // OVERVIEW ANALYTICS CARD
  Widget _buildOverviewBanner({
    required int totalCourses,
    required int inProgressCount,
    required int completedCount,
    required double avgProgress,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334B489B),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR LEARNING JOURNEY',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overall Progress: ${avgProgress.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Overall Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: avgProgress / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withAlpha(50),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
            ),
          ),
          const SizedBox(height: 16),

          // Metrics Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('TOTAL ENROLLED', '$totalCourses Courses'),
              _buildStatDivider(),
              _buildStatItem('IN PROGRESS', '$inProgressCount Active'),
              _buildStatDivider(),
              _buildStatItem('CERTIFIED', '$completedCount Completed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white24,
    );
  }

  // JOINED COURSE ITEM CARD BUILDER
  Widget _buildJoinedCourseCard(BuildContext context, JoinedCourseEntity course) {
    final isCompleted = course.progressPercentage >= 100;
    final formattedDate = DateFormat('dd MMM yyyy').format(course.joinedDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
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
          onTap: () => context.push('${RoutePaths.courseDetail}?id=${course.courseId}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Image Poster with Top Right Brand Logo Badge
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: course.imageUrl,
                            width: 85,
                            height: 75,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 85,
                              height: 75,
                              color: AppColors.primary,
                              child: const Icon(Icons.school_rounded, color: Colors.white),
                            ),
                          ),
                        ),
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
                    const SizedBox(width: 14),

                    // Title & Progress Specs
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isCompleted ? AppColors.success : AppColors.primary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  isCompleted ? '✓ COMPLETED' : 'IN PROGRESS',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              Text(
                                'Joined $formattedDate',
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Completion Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Course Completion Progress',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${course.progressPercentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? AppColors.success : AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: course.progressPercentage / 100,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFEEF2FF),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ACTION BUTTONS ROW: CONTINUE LEARNING & WHATSAPP GROUP
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            elevation: 0,
                          ),
                          onPressed: () => context.push(RoutePaths.courseMaterial),
                          icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
                          label: Text(
                            isCompleted ? 'REVISIT MODULES' : 'CONTINUE LEARNING',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: const Color(0xFFECFDF5),
                          ),
                          onPressed: () {
                            WhatsAppService.joinWhatsAppGroup(
                              context: context,
                              courseId: course.courseId,
                              courseTitle: course.title,
                            );
                          },
                          icon: const Icon(Icons.groups_rounded, color: Color(0xFF059669), size: 18),
                          label: const Text(
                            'STUDY GROUP',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // EMPTY STATE BUILDER
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 72, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              'No Joined Courses Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore certified courses in Bach Flower, Vastu Shastra & Ayurveda and enroll to start your learning journey.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.go(RoutePaths.courses),
              child: const Text('Explore Certified Courses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
