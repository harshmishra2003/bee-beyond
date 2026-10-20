import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../../routing/route_paths.dart';
import '../providers/course_provider.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  static const List<String> moduleTitles = [
    'Introduction & 38 Bach Essences Overview',
    'Remedy Selection, Preparation & Prescriptions',
    'Clinical Case Studies & Diagnostic Therapy',
    'Emotional Balance, Panic & Mind Release',
    'Practical Dosage, Patient Care & Final Certification',
  ];

  void _openTrailerModal(
    BuildContext context, {
    required String courseTitle,
    required String imageUrl,
    required String trailerUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CourseTrailerPlayerModal(
        courseTitle: courseTitle,
        imageUrl: imageUrl,
        trailerUrl: trailerUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Course Details'),
      body: courseAsync.when(
        data: (course) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Banner with Badges & Play Trailer Overlay
              GestureDetector(
                onTap: () => _openTrailerModal(
                  context,
                  courseTitle: course.title,
                  imageUrl: course.imageUrl,
                  trailerUrl: course.trailerUrl,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      child: course.imageUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: course.imageUrl,
                              width: double.infinity,
                              height: 230,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                height: 230,
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.school, size: 64, color: AppColors.primary),
                              ),
                            )
                          : Container(
                              height: 230,
                              color: AppColors.primaryDark,
                              child: const Icon(Icons.school, size: 64, color: Colors.white),
                            ),
                    ),

                    // Dark Overlay Gradient
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Top Right Tag: ONLINE CERTIFIED COURSE & Logo Emblem
                    Positioned(
                      top: 12,
                      right: 14,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: const Text(
                              'ONLINE CERTIFIED COURSE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 9.5,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                AssetPaths.beeBeyondImage2,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center Video Preview Play Button
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Watch HD Trailer',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Color(0x1A4B489B), blurRadius: 6),
                            ],
                          ),
                          child: Text(
                            course.category,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (course.subCategory != null && course.subCategory!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Color(0x1A4B489B), blurRadius: 6),
                              ],
                            ),
                            child: Text(
                              course.subCategory!,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Course Title
                    Text(
                      course.title,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 21,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Metrics Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F0FC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem(Icons.star_rounded, '${course.rating} Rating', Colors.amber),
                          _buildMetricDivider(),
                          _buildMetricItem(Icons.access_time_rounded, course.duration, AppColors.primary),
                          _buildMetricDivider(),
                          _buildMetricItem(Icons.menu_book_rounded, '${course.modulesCount} Modules', AppColors.primary),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // About Course
                    Text(
                      'About Course',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                        fontSize: 13.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // What You Will Learn Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0C4B489B), blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'What You Will Learn',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildCheckItem('38 Bach Flower Remedies selection & dosage'),
                          _buildCheckItem('Practical clinical diagnosis & case study analysis'),
                          _buildCheckItem('Official Certificate of Completion with Student ID'),
                          _buildCheckItem('Direct 24x7 WhatsApp Study Group Access'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Curriculum Header
                    Text(
                      'Course Curriculum & Modules',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Modules List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: course.modulesCount,
                      itemBuilder: (context, index) {
                        final modTitle = moduleTitles[index % moduleTitles.length];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0A4B489B), blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            onTap: () => _openTrailerModal(
                              context,
                              courseTitle: 'Module ${index + 1}: $modTitle',
                              imageUrl: course.imageUrl,
                              trailerUrl: course.trailerUrl,
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              'Module ${index + 1}: $modTitle',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            subtitle: const Row(
                              children: [
                                Icon(Icons.ondemand_video_rounded, size: 13, color: AppColors.textSecondary),
                                SizedBox(width: 4),
                                Text(
                                  'Video Lecture + PDF Study Guide',
                                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading course: $err')),
      ),
      bottomNavigationBar: courseAsync.maybeWhen(
        data: (course) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F4B489B),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registration Fee',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          CurrencyUtils.formatINR(course.price),
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ThreeDButton(
                        text: 'Enroll Now →',
                        fontSize: 14.5,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        onPressed: () {
                          context.push('${RoutePaths.courseEnrollment}?id=${course.id}');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 18,
      color: AppColors.borderSubtle,
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HIGH DEFINITION INTERACTIVE COURSE TRAILER VIDEO PLAYER MODAL
class _CourseTrailerPlayerModal extends StatefulWidget {
  final String courseTitle;
  final String imageUrl;
  final String trailerUrl;

  const _CourseTrailerPlayerModal({
    required this.courseTitle,
    required this.imageUrl,
    required this.trailerUrl,
  });

  @override
  State<_CourseTrailerPlayerModal> createState() => _CourseTrailerPlayerModalState();
}

class _CourseTrailerPlayerModalState extends State<_CourseTrailerPlayerModal> {
  bool _isPlaying = true;
  bool _isMuted = false;
  bool _isLandscape = false;
  double _progress = 0.35;
  String _selectedQuality = '1080p HD';

  final List<String> _qualityOptions = ['1080p HD', '720p HD', '480p SD', 'Auto'];

  @override
  void dispose() {
    // Always restore portrait orientation when player closes
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _isLandscape
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Modal Header Bar
            if (!_isLandscape) ...[
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.movie_filter_rounded, color: Colors.amberAccent, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'COURSE VIDEO TRAILER PREVIEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () {
                        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Video Display Container
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: widget.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.primaryDark,
                              child: const Icon(Icons.ondemand_video_rounded, color: Colors.white, size: 64),
                            ),
                          )
                        : Container(
                            color: AppColors.primaryDark,
                            child: const Icon(Icons.ondemand_video_rounded, color: Colors.white, size: 64),
                          ),
                  ),

                  // Dark Video Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Colors.black87,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Top Video Info Bar (Title, Quality Badge, Mute Button)
                  Positioned(
                    top: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.courseTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Quality Badge Menu
                        PopupMenuButton<String>(
                          initialValue: _selectedQuality,
                          color: const Color(0xFF1E1B4B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) => setState(() => _selectedQuality = val),
                          itemBuilder: (ctx) => _qualityOptions
                              .map((q) => PopupMenuItem(
                                    value: q,
                                    child: Text(
                                      q,
                                      style: TextStyle(
                                        color: _selectedQuality == q ? Colors.amberAccent : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.hd_rounded, size: 14, color: Color(0xFF1E1B4B)),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedQuality,
                                  style: const TextStyle(
                                    color: Color(0xFF1E1B4B),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Mute Toggle Button
                        GestureDetector(
                          onTap: () => setState(() => _isMuted = !_isMuted),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black48,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38),
                            ),
                            child: Icon(
                              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Video Play/Pause Overlay Controls
                  Positioned.fill(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 36,
                            icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _progress = (_progress - 0.1).clamp(0.0, 1.0);
                              });
                            },
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => setState(() => _isPlaying = !_isPlaying),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(color: Colors.black48, blurRadius: 12),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: AppColors.primary,
                                size: 44,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            iconSize: 36,
                            icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _progress = (_progress + 0.1).clamp(0.0, 1.0);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Controls Bar (Slider & Rotation Fullscreen Button)
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.5,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            activeTrackColor: Colors.amberAccent,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.amberAccent,
                          ),
                          child: Slider(
                            value: _progress,
                            onChanged: (val) => setState(() => _progress = val),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_progress * 15).toInt()}:12 / 15:00',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),

                              // Screen Rotation / Fullscreen Toggle Button
                              GestureDetector(
                                onTap: _toggleOrientation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isLandscape ? Icons.screen_lock_portrait_rounded : Icons.screen_rotation_rounded,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isLandscape ? 'Portrait Mode' : 'Rotate Screen',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
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
          ],
        ),
      ),
    );
  }
}
