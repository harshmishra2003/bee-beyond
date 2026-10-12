import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/widgets/animated_clock_icon.dart';
import '../../../../core/widgets/shining_view_all_button.dart';

class OurCoursesSection extends StatelessWidget {
  final VoidCallback onViewAllTap;
  final Function(String courseId) onCourseTap;

  const OurCoursesSection({
    super.key,
    required this.onViewAllTap,
    required this.onCourseTap,
  });

  static const List<Map<String, dynamic>> ourCourses = [
    {
      'id': 'c_1',
      'title': 'Certified Bach Flower Therapy & Healing Course',
      'price': '₹ 2,499',
      'originalPrice': '₹ 3,500',
      'duration': '24 Hours',
      'rating': '4.9',
      'category': 'Bach Flower',
      'badge': 'BESTSELLER',
      'image': AssetPaths.ancientHealing,
    },
    {
      'id': 'c_2',
      'title': 'Ayurvedic Lifestyle & Drugless Upchar Diploma',
      'price': '₹ 3,999',
      'originalPrice': '₹ 5,000',
      'duration': '32 Hours',
      'rating': '4.8',
      'category': 'Ayurvedic Upchar',
      'badge': 'POPULAR',
      'image': AssetPaths.bachFlower,
    },
    {
      'id': 'c_6',
      'title': 'Advanced Vastu Shastra Certification',
      'price': '₹ 4,999',
      'originalPrice': '₹ 7,500',
      'duration': '40 Hours',
      'rating': '5.0',
      'category': 'Vastu',
      'badge': 'PREMIUM',
      'image': AssetPaths.vastu,
    },
    {
      'id': 'c_3',
      'title': 'Mind & Life Coaching Masterclass',
      'price': '₹ 2,999',
      'originalPrice': '₹ 4,500',
      'duration': '20 Hours',
      'rating': '4.7',
      'category': 'Counselling',
      'badge': 'CERTIFIED',
      'image': AssetPaths.beeBeyondImage1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Ribbon Header
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
                  Icons.auto_awesome_rounded,
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
                      'OUR COURSES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Explore top featured programs',
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
            itemCount: ourCourses.length,
            itemBuilder: (context, index) {
              final course = ourCourses[index];
              return _OurCourseCard(
                course: course,
                onCourseTap: onCourseTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Oval-Rectangular Compact Our Course Card
class _OurCourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final Function(String courseId) onCourseTap;

  const _OurCourseCard({
    required this.course,
    required this.onCourseTap,
  });

  @override
  State<_OurCourseCard> createState() => _OurCourseCardState();
}

class _OurCourseCardState extends State<_OurCourseCard> {
  bool _isEnrolled = false;
  bool _isEnrolling = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.course['id'] as String;
    final title = widget.course['title'] as String;
    final price = widget.course['price'] as String;
    final originalPrice = widget.course['originalPrice'] as String;
    final duration = widget.course['duration'] as String;
    final rating = widget.course['rating'] as String;
    final category = widget.course['category'] as String;
    final badge = widget.course['badge'] as String;
    final image = widget.course['image'] as String;

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
        onTap: () => widget.onCourseTap(id),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Poster
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

                // Top Left Rating Tag
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.amber, width: 0.7),
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

                // Bottom Right Discount Tag
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'SPECIAL OFFER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 7.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Details
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

                  // Price Display Row
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFF1E1B4B),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        originalPrice,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                          fontSize: 9.5,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Action Pills Row
                  Row(
                    children: [
                      // Duration
                      Expanded(
                        flex: 4,
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
                      const SizedBox(width: 4),

                      // Enroll Button
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () async {
                            if (_isEnrolled) {
                              widget.onCourseTap(id);
                              return;
                            }

                            setState(() => _isEnrolling = true);
                            await Future.delayed(const Duration(milliseconds: 250));

                            if (mounted) {
                              setState(() {
                                _isEnrolling = false;
                                _isEnrolled = true;
                              });
                              widget.onCourseTap(id);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isEnrolled
                                    ? [const Color(0xFF059669), const Color(0xFF10B981)]
                                    : [const Color(0xFF4338CA), const Color(0xFF312E81)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isEnrolling) ...[
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
                                  Icon(
                                    _isEnrolled ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                                    size: 9.5,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 2),
                                ],
                                Flexible(
                                  child: Text(
                                    _isEnrolling
                                        ? 'Opening...'
                                        : (_isEnrolled ? 'Enrolled ✓' : 'Enroll Now'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
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
