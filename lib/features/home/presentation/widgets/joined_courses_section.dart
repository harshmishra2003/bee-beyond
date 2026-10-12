import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/widgets/animated_clock_icon.dart';
import '../../../../core/widgets/shining_view_all_button.dart';

class JoinedCoursesSection extends StatelessWidget {
  final VoidCallback onViewAllTap;
  final Function(String courseId) onLearnTap;
  final Function(String courseId) onJoinGroupTap;

  const JoinedCoursesSection({
    super.key,
    required this.onViewAllTap,
    required this.onLearnTap,
    required this.onJoinGroupTap,
  });

  static const List<Map<String, dynamic>> joinedCourses = [
    {
      'id': 'c_1',
      'title': 'Certified Bach Flower Therapy & Healing Course',
      'duration': '24 Hours',
      'modules': '12 Modules',
      'progress': 0.75,
      'progressText': '75% Done',
      'rating': '4.9',
      'students': '2.4k',
      'image': AssetPaths.ancientHealing,
      'category': 'Bach Flower',
      'badge': 'ONLINE CERTIFIED',
    },
    {
      'id': 'c_2',
      'title': 'Ayurvedic Lifestyle & Drugless Upchar Diploma',
      'duration': '32 Hours',
      'modules': '16 Modules',
      'progress': 0.45,
      'progressText': '45% Done',
      'rating': '4.8',
      'students': '1.8k',
      'image': AssetPaths.bachFlower,
      'category': 'Ayurvedic Upchar',
      'badge': 'POPULAR COURSE',
    },
    {
      'id': 'c_6',
      'title': 'Advanced Vastu Shastra Certification',
      'duration': '40 Hours',
      'modules': '20 Modules',
      'progress': 0.90,
      'progressText': '90% Done',
      'rating': '5.0',
      'students': '3.1k',
      'image': AssetPaths.vastu,
      'category': 'Vastu',
      'badge': 'DIPLOMA COURSE',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                      'JOINED COURSES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Continue learning journey',
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

        // Sleek Compact Oval-Rectangular Horizontal List
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: joinedCourses.length,
            itemBuilder: (context, index) {
              final course = joinedCourses[index];
              return _JoinedCourseCard(
                course: course,
                onLearnTap: onLearnTap,
                onJoinGroupTap: onJoinGroupTap,
              );
            },
          ),
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
  bool _isJoined = false;
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
            Color(0xFF130F2A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.65),
          width: 1.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x400F0C20),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => widget.onLearnTap(id),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Thumbnail
            Stack(
              children: [
                _buildCourseImage(image),

                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x50000000),
                          Color(0x00000000),
                          Color(0x70000000),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Top Right Badge
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 7.5,
                      ),
                    ),
                  ),
                ),

                // Top Left Progress Tag
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amberAccent, width: 0.7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, size: 8.5, color: Colors.amberAccent),
                        const SizedBox(width: 2),
                        Text(
                          progressText,
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 7.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Left Modules
                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF312E81),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      modules,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),

                // Bottom Right Rating
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 9, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Details Body
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF4338CA),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 1),

                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E1B4B),
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Compact Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFF4338CA),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3.5,
                          backgroundColor: const Color(0xFFE0E7FF),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Compact Action Pills Row
                  Row(
                    children: [
                      // Duration
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFC7D2FE), width: 0.8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const AnimatedClockIcon(size: 9.5, color: Color(0xFF312E81)),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  duration,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF312E81),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),

                      // Learn
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _isLearnPressed = true),
                          onTapUp: (_) {
                            setState(() => _isLearnPressed = false);
                            widget.onLearnTap(id);
                          },
                          onTapCancel: () => setState(() => _isLearnPressed = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isLearnPressed
                                    ? [const Color(0xFF059669), const Color(0xFF10B981)]
                                    : [const Color(0xFF4338CA), const Color(0xFF312E81)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isLearnPressed ? Icons.play_arrow_rounded : Icons.menu_book_rounded,
                                  size: 9.5,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _isLearnPressed ? 'Resume' : 'Learn',
                                  style: const TextStyle(
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
                      const SizedBox(width: 3),

                      // Join WhatsApp Group
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _isJoining = true);
                            await Future.delayed(const Duration(milliseconds: 250));

                            if (mounted) {
                              setState(() {
                                _isJoining = false;
                                _isJoined = true;
                              });

                              await WhatsAppService.joinWhatsAppGroup(
                                context: context,
                                courseId: id,
                                courseTitle: title,
                              );

                              widget.onJoinGroupTap(id);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isJoining) ...[
                                  const SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                ] else ...[
                                  const Icon(
                                    Icons.forum_rounded,
                                    size: 9.5,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 2),
                                ],
                                const Flexible(
                                  child: Text(
                                    'Join Group',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.2,
                                      fontWeight: FontWeight.w800,
                                    ),
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
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildCourseImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        height: 85,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 85,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 85,
          color: const Color(0xFFE0E7FF),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 85,
      color: const Color(0xFFEEF2FF),
      child: const Center(
        child: Icon(Icons.school_rounded, size: 30, color: Color(0xFF4338CA)),
      ),
    );
  }
}
