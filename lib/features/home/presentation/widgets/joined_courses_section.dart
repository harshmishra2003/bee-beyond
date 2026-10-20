import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/widgets/animated_clock_icon.dart';
import '../../../../core/widgets/shining_view_all_button.dart';
import '../../../courses/presentation/providers/course_provider.dart';

class JoinedCoursesSection extends ConsumerWidget {
  final VoidCallback onViewAllTap;
  final Function(String courseId) onLearnTap;
  final Function(String courseId) onJoinGroupTap;

  const JoinedCoursesSection({
    super.key,
    required this.onViewAllTap,
    required this.onLearnTap,
    required this.onJoinGroupTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinedAsync = ref.watch(joinedCoursesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Ribbon Header with Periodic Shining "View All" Button
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
                  color: Colors.amber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.amberAccent,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY JOINED COURSES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Your enrolled learning programs',
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

        joinedAsync.when(
          data: (courses) {
            if (courses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: Color(0xFF4338CA),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No Joined Courses Yet',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Explore certified courses and enroll to start learning.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: onViewAllTap,
                              child: const Text(
                                'Explore Courses Catalog →',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4338CA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final c = courses[index];
                  return _JoinedCourseCard(
                    course: {
                      'id': c.courseId,
                      'title': c.title,
                      'duration': 'Self-Paced',
                      'modules': '12 Modules',
                      'progress': (c.progressPercentage / 100.0).clamp(0.0, 1.0),
                      'progressText': '${c.progressPercentage.toInt()}% Done',
                      'rating': '4.9',
                      'students': '2.1k',
                      'image': c.imageUrl.isNotEmpty ? c.imageUrl : AssetPaths.ancientHealing,
                      'category': 'Certified',
                      'badge': 'ENROLLED',
                    },
                    onLearnTap: onLearnTap,
                    onJoinGroupTap: onJoinGroupTap,
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Oval-Rectangular Compact Course Card surrounded by a Dark Frame
class _JoinedCourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final Function(String courseId) onLearnTap;
  final Function(String courseId) onJoinGroupTap;

  const _JoinedCourseCard({
    required this.course,
    required this.onLearnTap,
    required this.onJoinGroupTap,
  });

  @override
  State<_JoinedCourseCard> createState() => _JoinedCourseCardState();
}

class _JoinedCourseCardState extends State<_JoinedCourseCard> {
  bool _isJoining = false;
  bool _isLearnPressed = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.course['id'] as String;
    final title = widget.course['title'] as String;
    final duration = widget.course['duration'] as String;
    final modules = widget.course['modules'] as String;
    final progress = widget.course['progress'] as double;
    final progressText = widget.course['progressText'] as String;
    final rating = widget.course['rating'] as String;
    final image = widget.course['image'] as String;
    final category = widget.course['category'] as String;
    final badge = widget.course['badge'] as String;

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      // SLEEK OVAL-RECTANGULAR DARK FRAME
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F0C20),
            Color(0xFF1E1B4B),
            Color(0xFF2E1065),
            Color(0xFF0F0C20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x300F0C20),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP POSTER IMAGE WITH BADGES
            SizedBox(
              height: 90,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _buildCourseImage(image),
                  ),

                  // TOP GRADIENT OVERLAY
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent, Colors.black38],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // BADGE TOP-LEFT
                  Positioned(
                    top: 6,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF312E81),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.indigoAccent, width: 0.8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),

                  // RATING TOP-RIGHT
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 11),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CARD CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // CATEGORY & DURATION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF4338CA),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            const AnimatedClockIcon(size: 10, color: Color(0xFF64748B)),
                            const SizedBox(width: 2),
                            Text(
                              '$duration • $modules',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // TITLE
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.15,
                      ),
                    ),

                    // PROGRESS BAR
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'COURSE PROGRESS',
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              progressText,
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4.5,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),

                    // 2 DUAL ACTION BUTTONS (Start Learning + WhatsApp Study Group)
                    Row(
                      children: [
                        // Start Learning Button
                        Expanded(
                          flex: 6,
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => _isLearnPressed = true),
                            onTapUp: (_) => setState(() => _isLearnPressed = false),
                            onTapCancel: () => setState(() => _isLearnPressed = false),
                            onTap: () => widget.onLearnTap(id),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 100),
                              scale: _isLearnPressed ? 0.96 : 1.0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF312E81), Color(0xFF4338CA)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x20312E81),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 11),
                                    SizedBox(width: 3),
                                    Text(
                                      'Start Learn',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Join WhatsApp Study Group Button
                        Expanded(
                          flex: 5,
                          child: GestureDetector(
                            onTap: () async {
                              setState(() => _isJoining = true);
                              await WhatsAppService.joinWhatsAppGroup(
                                context: context,
                                courseId: id,
                                courseTitle: title,
                              );
                              if (mounted) {
                                setState(() => _isJoining = false);
                                widget.onJoinGroupTap(id);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2025D366),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _isJoining
                                  ? const SizedBox(
                                      height: 11,
                                      width: 11,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.groups_rounded, color: Colors.white, size: 11),
                                        SizedBox(width: 3),
                                        Text(
                                          'Study Group',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildCourseImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        height: 90,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 90,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 90,
          width: double.infinity,
          color: const Color(0xFFF1F5F9),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 90,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.school_rounded, color: Color(0xFF4338CA), size: 30),
    );
  }
}
