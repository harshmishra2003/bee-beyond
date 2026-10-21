import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_pdf_book_viewer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../../routing/route_paths.dart';
import '../../domain/entities/course_entity.dart';
import '../providers/course_provider.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openPdfViewerModal(
    BuildContext context, {
    required String pdfTitle,
    required String pdfUrl,
    String? description,
  }) {
    AppPdfBookViewer.show(
      context,
      title: pdfTitle,
      pdfUrl: pdfUrl,
      description: description,
    );
  }

  void _showTextLessonDialog(
    BuildContext context, {
    required String lessonTitle,
    required String lessonContent,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.article_rounded, color: Color(0xFF059669), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                lessonTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Text(
            lessonContent.isNotEmpty
                ? lessonContent
                : 'Text lesson notes, reading guides, and practitioner clinical observations.',
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textPrimary),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchVideoUrl(BuildContext context, String url, String title) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isNotEmpty && (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://'))) {
      final Uri uri = Uri.parse(cleanUrl);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening video lecture "$title"...'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final joinedCoursesAsync = ref.watch(joinedCoursesProvider);

    final isEnrolled = joinedCoursesAsync.maybeWhen(
      data: (list) => list.any((c) => c.courseId == widget.courseId),
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Course Details'),
      body: courseAsync.when(
        data: (course) {
          // Dynamic Learnings extracted directly from Admin Feed or Description
          List<String> learningsList = [];
          if (course.learnings.isNotEmpty) {
            learningsList = course.learnings;
          } else if (course.description.isNotEmpty) {
            final rawSplit = course.description
                .split(RegExp(r'[\r\n;•|]+'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();

            if (rawSplit.length >= 2) {
              learningsList = rawSplit;
            } else {
              learningsList = [
                'In-depth clinical study & practical application of ${course.title}',
                course.description,
                'Official Certificate of Completion with Verified Practitioner ID',
              ];
            }
          } else {
            learningsList = [
              'In-depth study & practical application of ${course.title}',
              'Official Certificate of Completion with Verified Student ID',
            ];
          }

          final hasCustomModules = course.modulesList.isNotEmpty;
          final totalModulesCount =
              hasCustomModules ? course.modulesList.length : course.modulesCount;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HERO COURSE BANNER
                      _CourseHeroBanner(course: course),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category & Subcategory Chips
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
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
                                if (course.subCategory != null &&
                                    course.subCategory!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(20),
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
                                fontSize: 20,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Metrics Bar Card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.borderSubtle, width: 1.2),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x0A4B489B),
                                      blurRadius: 8,
                                      offset: Offset(0, 3)),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildMetricItem(
                                      Icons.star_rounded,
                                      '${course.rating} Rating',
                                      Colors.amber),
                                  _buildMetricDivider(),
                                  _buildMetricItem(
                                      Icons.access_time_rounded,
                                      course.duration,
                                      AppColors.primary),
                                  _buildMetricDivider(),
                                  _buildMetricItem(
                                      Icons.menu_book_rounded,
                                      '$totalModulesCount Modules',
                                      AppColors.primary),
                                ],
                              ),
                            ),

                            if (isEnrolled) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Color(0xFF059669), size: 22),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'You are currently enrolled in this course. Access all modules below.',
                                        style: TextStyle(
                                          color: Color(0xFF065F46),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // TAB BAR FOR OVERVIEW & CURRICULUM
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13.5),
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Curriculum & Modules'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // OVERVIEW TAB CONTENT
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Course
                      const Text(
                        'About This Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description.isNotEmpty
                            ? course.description
                            : 'Detailed curriculum and description for ${course.title}.',
                        maxLines: _isDescriptionExpanded ? null : 4,
                        overflow: _isDescriptionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (course.description.length > 150)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              _isDescriptionExpanded ? 'Read Less ▲' : 'Read More ▼',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // What You Will Learn Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.borderSubtle, width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x0C4B489B),
                                blurRadius: 8,
                                offset: Offset(0, 3)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified_rounded,
                                    color: AppColors.primary, size: 20),
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
                            const SizedBox(height: 12),
                            ...learningsList.map((item) => _buildCheckItem(item)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // CURRICULUM TAB CONTENT
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Course Content',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '$totalModulesCount Lessons',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (hasCustomModules)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: course.modulesList.length,
                          itemBuilder: (context, index) {
                            final module = course.modulesList[index];
                            final isPdf = module.type.toLowerCase() == 'pdf';
                            final isText = module.type.toLowerCase() == 'text';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.borderSubtle, width: 1.2),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x0A4B489B),
                                      blurRadius: 6,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  onTap: () {
                                    if (isPdf) {
                                      _openPdfViewerModal(
                                        context,
                                        pdfTitle: module.title,
                                        pdfUrl: module.mediaUrl,
                                        description: module.description,
                                      );
                                    } else if (isText) {
                                      _showTextLessonDialog(
                                        context,
                                        lessonTitle: module.title,
                                        lessonContent: module.description,
                                      );
                                    } else {
                                      _launchVideoUrl(
                                          context, module.mediaUrl, module.title);
                                    }
                                  },
                                  leading: Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isPdf
                                          ? const Color(0xFFFEF2F2)
                                          : (isText
                                              ? const Color(0xFFECFDF5)
                                              : AppColors.primary.withValues(alpha: 0.12)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPdf
                                          ? Icons.picture_as_pdf_rounded
                                          : (isText
                                              ? Icons.article_rounded
                                              : Icons.play_arrow_rounded),
                                      color: isPdf
                                          ? const Color(0xFFEF4444)
                                          : (isText
                                              ? const Color(0xFF059669)
                                              : AppColors.primary),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    module.title,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Icon(
                                        isPdf
                                            ? Icons.menu_book_rounded
                                            : (isText
                                                ? Icons.description_outlined
                                                : Icons.play_circle_outline_rounded),
                                        size: 13,
                                        color: isPdf
                                            ? const Color(0xFFEF4444)
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          isPdf
                                              ? 'PDF Study Guide • ${module.durationOrSize}'
                                              : (isText
                                                  ? 'Text Lesson • ${module.durationOrSize}'
                                                  : 'Video Lecture • ${module.durationOrSize}'),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: isPdf
                                                ? const Color(0xFFEF4444)
                                                : AppColors.textSecondary,
                                            fontWeight: isPdf
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    isPdf
                                        ? Icons.open_in_new_rounded
                                        : (isText
                                            ? Icons.read_more_rounded
                                            : Icons.play_circle_fill_rounded),
                                    color: isPdf
                                        ? const Color(0xFFEF4444)
                                        : (isText
                                            ? const Color(0xFF059669)
                                            : AppColors.primary),
                                    size: 26,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.borderSubtle, width: 1.2),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.menu_book_rounded,
                                  color: AppColors.primary, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Curriculum & Modules Uploading',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Our practitioners are finalizing study notes and video lectures.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Error loading course details: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(
                      courseDetailProvider(widget.courseId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: courseAsync.maybeWhen(
        data: (course) => SafeArea(
          child: Container(
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
                    text: isEnrolled ? 'Go To Course →' : 'Enroll Now →',
                    fontSize: 14.5,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    onPressed: () {
                      context.push(
                          '${RoutePaths.courseEnrollment}?id=${course.id}');
                    },
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HERO COURSE BANNER WIDGET
class _CourseHeroBanner extends StatelessWidget {
  final CourseEntity course;

  const _CourseHeroBanner({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFE0E7FF),
            Color(0xFFC7D2FE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF818CF8), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x254F46E5),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 230,
          width: double.infinity,
          color: const Color(0xFF0F172A),
          child: course.imageUrl.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: course.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain, // FULL COURSE IMAGE VISIBLE WITHOUT CUT OFF
                  placeholder: (context, url) => const SizedBox(
                    height: 230,
                    child: Center(child: CircularProgressIndicator(color: Colors.amberAccent)),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholderPoster(),
                )
              : _buildPlaceholderPoster(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPoster() {
    return Container(
      height: 230,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0C20), Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_rounded, size: 54, color: Colors.amberAccent),
          SizedBox(height: 8),
          Text(
            'Bee Beeyond Holistic Academy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// IN-APP NATIVE PDF READER MODAL WIDGET
class _CoursePdfViewerModal extends StatefulWidget {
  final String pdfTitle;
  final String pdfUrl;
  final String? description;

  const _CoursePdfViewerModal({
    required this.pdfTitle,
    required this.pdfUrl,
    this.description,
  });

  @override
  State<_CoursePdfViewerModal> createState() => _CoursePdfViewerModalState();
}

class _CoursePdfViewerModalState extends State<_CoursePdfViewerModal> {
  static const String _fallbackPdfUrl =
      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

  Uint8List? _pdfBytes;
  bool _isLoadingPdf = true;
  String? _errorMessage;
  bool _isUsingFallback = false;

  @override
  void initState() {
    super.initState();
    _downloadPdfBytes(widget.pdfUrl);
  }

  Future<void> _downloadPdfBytes(String rawUrl) async {
    final url = rawUrl.trim();
    final targetUrl = (url.isNotEmpty && url.startsWith('http'))
        ? url
        : _fallbackPdfUrl;

    if (targetUrl == _fallbackPdfUrl) {
      _isUsingFallback = true;
    }

    if (mounted) {
      setState(() {
        _isLoadingPdf = true;
        _errorMessage = null;
      });
    }

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.bytes,
      ));

      final response = await dio.get<List<int>>(targetUrl);
      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        if (bytes.length >= 100) {
          if (mounted) {
            setState(() {
              _pdfBytes = bytes;
              _isLoadingPdf = false;
            });
          }
          return;
        }
      }

      if (!_isUsingFallback) {
        _isUsingFallback = true;
        _downloadPdfBytes(_fallbackPdfUrl);
      } else {
        if (mounted) {
          setState(() {
            _pdfBytes = null;
            _isLoadingPdf = false;
            _errorMessage = 'The file at this URL is not a valid PDF document.';
          });
        }
      }
    } catch (e) {
      if (!_isUsingFallback) {
        _isUsingFallback = true;
        _downloadPdfBytes(_fallbackPdfUrl);
      } else {
        if (mounted) {
          setState(() {
            _pdfBytes = null;
            _isLoadingPdf = false;
            _errorMessage =
                'Could not download PDF document. Please check network connection.';
          });
        }
      }
    }
  }

  Future<void> _openExternalPdf() async {
    final url = widget.pdfUrl.trim().isNotEmpty
        ? widget.pdfUrl.trim()
        : _fallbackPdfUrl;

    if (url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      final Uri uri = Uri.parse(url);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening PDF document for "${widget.pdfTitle}"...'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pdfTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Text(
                        'In-App Official Study PDF',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.close_rounded, color: AppColors.primary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // PDF VIEW BODY
          Expanded(
            child: _isLoadingPdf
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFEF4444)),
                        SizedBox(height: 16),
                        Text(
                          'Downloading & Rendering PDF In-App...',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please wait a moment',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                : (_pdfBytes != null
                    ? PdfPreview(
                        build: (format) async => _pdfBytes!,
                        useActions: true,
                        allowPrinting: true,
                        allowSharing: true,
                        canChangeOrientation: false,
                        pdfFileName: '${widget.pdfTitle}.pdf',
                        loadingWidget: const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        onError: (context, error) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded,
                                    color: Color(0xFFEF4444), size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  widget.pdfTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Could not render PDF: $error',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.5),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                  ),
                                  onPressed: _openExternalPdf,
                                  icon: const Icon(Icons.open_in_new_rounded,
                                      color: Colors.white, size: 18),
                                  label: const Text(
                                    'Open Original PDF File',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF2F2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.picture_as_pdf_rounded,
                                    color: Color(0xFFEF4444), size: 48),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.pdfTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage ??
                                    'PDF document available for enrolled students.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.5),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                onPressed: _openExternalPdf,
                                icon: const Icon(Icons.open_in_new_rounded,
                                    color: Colors.white, size: 18),
                                label: const Text(
                                  'Open Original PDF File',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
          ),
        ],
      ),
    );
  }
}
