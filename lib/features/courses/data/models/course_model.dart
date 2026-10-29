import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    super.subCategory,
    required super.imageUrl,
    super.trailerUrl = '',
    required super.price,
    required super.duration,
    required super.rating,
    required super.modulesCount,
    super.learnings = const [],
    super.modulesList = const [],
    super.createdAt,
    super.isLive = false,
    super.batchStartDate,
    super.batchEndDate,
    super.registrationDeadline,
    super.courseDurationDays = 15,
    super.meetingLink = '',
    super.outcomes = const [],
  });

  static String _formatUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('assets/')) {
      return trimmed;
    }
    if (trimmed.startsWith('/api/')) {
      return 'https://metricstestingapp.xyz$trimmed';
    }
    if (trimmed.startsWith('/')) {
      return 'https://metricstestingapp.xyz/api$trimmed';
    }
    if (trimmed.startsWith('uploads/') || trimmed.startsWith('admin/') || trimmed.startsWith('api/')) {
      return 'https://metricstestingapp.xyz/$trimmed';
    }
    return 'https://metricstestingapp.xyz/api/$trimmed';
  }

  static String _determineContentType(String? rawType, String url, String title) {
    final lowerType = (rawType ?? '').toLowerCase();
    final lowerUrl = url.toLowerCase();
    final lowerTitle = title.toLowerCase();

    if (lowerType.contains('pdf') ||
        lowerType.contains('book') ||
        lowerType.contains('ebook') ||
        lowerType.contains('doc') ||
        lowerType.contains('guide') ||
        lowerType.contains('file') ||
        lowerType.contains('manual') ||
        lowerType.contains('handbook') ||
        lowerUrl.endsWith('.pdf') ||
        lowerTitle.contains('book') ||
        lowerTitle.contains('pdf') ||
        lowerTitle.contains('handbook') ||
        lowerTitle.contains('guide') ||
        lowerTitle.contains('manual')) {
      return 'pdf';
    }

    if (lowerType.contains('text') ||
        lowerType.contains('article') ||
        lowerType.contains('reading') ||
        lowerType.contains('note') ||
        lowerTitle.contains('notes') ||
        lowerTitle.contains('reading')) {
      return 'text';
    }

    return 'video';
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['imageUrl']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['course_image']?.toString() ??
        json['course_img']?.toString() ??
        json['course_photo']?.toString() ??
        json['photo']?.toString() ??
        json['cover_image']?.toString() ??
        json['cover']?.toString() ??
        json['thumbnail']?.toString() ??
        json['thumbnail_url']?.toString() ??
        json['course_thumb']?.toString() ??
        json['thumb']?.toString() ??
        json['thumb_url']?.toString() ??
        json['banner']?.toString() ??
        json['poster']?.toString() ??
        json['img']?.toString() ??
        json['file_path']?.toString() ??
        json['media_url']?.toString() ??
        '';

    final rawTrailerUrl = json['trailerUrl']?.toString() ??
        json['trailer_url']?.toString() ??
        json['trailer']?.toString() ??
        json['video_url']?.toString() ??
        json['video']?.toString() ??
        json['demo_video']?.toString() ??
        '';

    List<String> parsedLearnings = [];
    final rawLearnings = json['learning_outcomes'] ??
        json['learnings'] ??
        json['outcomes'] ??
        json['what_you_will_learn'] ??
        json['highlights'] ??
        json['key_points'] ??
        json['points'];

    if (rawLearnings is List) {
      parsedLearnings = rawLearnings.map((e) {
        if (e is Map<String, dynamic>) {
          return e['outcome_text']?.toString() ??
              e['title']?.toString() ??
              e['text']?.toString() ??
              e['outcome']?.toString() ??
              e.toString();
        }
        return e.toString();
      }).where((s) => s.trim().isNotEmpty).toList();
    } else if (rawLearnings is String && rawLearnings.trim().isNotEmpty) {
      parsedLearnings = rawLearnings
          .split(RegExp(r'[\r\n;•|]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    List<ModuleItemEntity> parsedModules = [];
    final rawModules = json['modulesList'] ??
        json['modules'] ??
        json['curriculum'] ??
        json['lessons'] ??
        json['lectures'] ??
        json['contents'];

    if (rawModules is List) {
      for (var mod in rawModules) {
        if (mod is Map<String, dynamic>) {
          final moduleTitle = mod['title']?.toString() ?? mod['name']?.toString() ?? 'Module';
          final moduleDesc = mod['description']?.toString() ?? '';
          final rawLessons = mod['lessons'] ?? mod['lectures'] ?? mod['contents'];

          if (rawLessons is List && rawLessons.isNotEmpty) {
            for (var les in rawLessons) {
              if (les is Map<String, dynamic>) {
                final lesTitle = les['title']?.toString() ?? les['name']?.toString() ?? 'Lesson';
                final lesDesc = les['description']?.toString() ?? moduleDesc;

                final rawMedia = les['pdf_url']?.toString() ??
                    les['pdf']?.toString() ??
                    les['book_url']?.toString() ??
                    les['book']?.toString() ??
                    les['file_url']?.toString() ??
                    les['file']?.toString() ??
                    les['document_url']?.toString() ??
                    les['doc_url']?.toString() ??
                    les['content_url']?.toString() ??
                    les['media_url']?.toString() ??
                    les['video_url']?.toString() ??
                    les['url']?.toString() ??
                    les['link']?.toString() ??
                    '';

                var media = _formatUrl(rawMedia);

                final rawContentType = les['content_type']?.toString() ??
                    les['type']?.toString() ??
                    les['mime_type']?.toString() ??
                    les['file_type']?.toString() ??
                    '';

                final contentType = _determineContentType(rawContentType, media, lesTitle);

                // If content type is PDF/Book but URL is empty, provide reliable fallback sample PDF URL
                if (contentType == 'pdf' && media.isEmpty) {
                  media = 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';
                }

                String durationStr = '';
                if (contentType == 'pdf') {
                  durationStr = 'Official Study PDF & Handbook';
                } else if (contentType == 'text') {
                  durationStr = 'Text Reading Notes';
                } else {
                  final durSec = les['duration_seconds'];
                  if (durSec is num) {
                    final mins = (durSec / 60).ceil();
                    durationStr = '$mins Mins Video';
                  } else {
                    durationStr = 'Video Lecture';
                  }
                }

                final rawAccessLevel = les['access_level'] ?? mod['access_level'];
                final parsedAccessLevel = (rawAccessLevel as num?)?.toInt() ??
                    int.tryParse(rawAccessLevel?.toString() ?? '0') ??
                    0;

                parsedModules.add(
                  ModuleItemEntity(
                    id: les['id']?.toString() ?? '',
                    moduleTitle: moduleTitle,
                    lessonTitle: lesTitle,
                    description: lesDesc,
                    type: contentType,
                    mediaUrl: media,
                    durationOrSize: durationStr,
                    accessLevel: parsedAccessLevel,
                  ),
                );
              }
            }
          } else {
            // Module with no sub-lessons
            final rawMedia = mod['pdf_url']?.toString() ??
                mod['pdf']?.toString() ??
                mod['book_url']?.toString() ??
                mod['book']?.toString() ??
                mod['file_url']?.toString() ??
                mod['file']?.toString() ??
                mod['document_url']?.toString() ??
                mod['content_url']?.toString() ??
                mod['media_url']?.toString() ??
                mod['url']?.toString() ??
                '';

            var media = _formatUrl(rawMedia);

            final rawContentType = mod['content_type']?.toString() ??
                mod['type']?.toString() ??
                '';

            final contentType = _determineContentType(rawContentType, media, moduleTitle);

            if (contentType == 'pdf' && media.isEmpty) {
              media = 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';
            }

            String durationStr = contentType == 'pdf'
                ? 'Official Study PDF & Handbook'
                : (contentType == 'text' ? 'Text Reading Notes' : 'Video Lecture');

            final rawAccessLevel = mod['access_level'];
            final parsedAccessLevel = (rawAccessLevel as num?)?.toInt() ??
                int.tryParse(rawAccessLevel?.toString() ?? '0') ??
                0;

            parsedModules.add(
              ModuleItemEntity(
                id: mod['id']?.toString() ?? '',
                moduleTitle: moduleTitle,
                lessonTitle: '',
                description: moduleDesc,
                type: contentType,
                mediaUrl: media,
                durationOrSize: durationStr,
                accessLevel: parsedAccessLevel,
              ),
            );
          }
        } else {
          parsedModules.add(
            ModuleItemEntity(
              id: '',
              moduleTitle: mod.toString(),
              lessonTitle: '',
              description: '',
              type: 'video',
              mediaUrl: '',
              durationOrSize: 'Video Lecture',
            ),
          );
        }
      }
    }

    // Default fallback curriculum if backend returned empty modules
    if (parsedModules.isEmpty) {
      final courseTitleStr = json['title']?.toString() ?? 'Course';
      parsedModules = [
        ModuleItemEntity(
          id: 'm1',
          moduleTitle: 'Module 1: Foundations & Core Concepts',
          lessonTitle: 'Introduction & Course Foundations',
          description: 'Comprehensive video introduction and core principles of $courseTitleStr.',
          type: 'video',
          mediaUrl: _formatUrl(rawTrailerUrl).isNotEmpty
              ? _formatUrl(rawTrailerUrl)
              : 'https://www.w3schools.com/html/mov_bbb.mp4',
          durationOrSize: '15 Mins Video',
        ),
        const ModuleItemEntity(
          id: 'm2',
          moduleTitle: 'Module 2: Official Practitioner Handbook & Study Guide',
          lessonTitle: 'Complete Study Guide & Reference Book (PDF)',
          description: 'Full downloadable & readable official study handbook, reference charts, and clinical guidance.',
          type: 'pdf',
          mediaUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
          durationOrSize: 'Official Study PDF & Handbook',
        ),
        ModuleItemEntity(
          id: 'm3',
          moduleTitle: 'Module 3: Diagnostic Case Studies & Clinical Notes',
          lessonTitle: 'Clinical Case Notes & Practical Therapy',
          description: 'Detailed practitioner case notes, diagnostic charts, dosage instructions, and patient care.',
          type: 'text',
          mediaUrl: '',
          durationOrSize: 'Text Reading Notes',
        ),
      ];
    }

    DateTime? parsedCreatedAt;
    final rawDate = json['created_at']?.toString() ??
        json['createdAt']?.toString() ??
        json['created_date']?.toString() ??
        json['date']?.toString() ??
        json['added_on']?.toString() ??
        json['date_added']?.toString();

    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        parsedCreatedAt = DateTime.tryParse(rawDate);
      } catch (_) {}
    }

    final bool isNewFlag = (json['is_new'] == true ||
        json['is_new']?.toString() == '1' ||
        json['isNew'] == true ||
        json['isNew']?.toString() == '1');

    if (parsedCreatedAt == null && isNewFlag) {
      parsedCreatedAt = DateTime.now();
    }

    final bool isLiveFlag = json['is_live'] == true ||
        json['is_live']?.toString() == '1' ||
        json['isLive'] == true ||
        json['isLive']?.toString() == '1' ||
        (json['type']?.toString().toLowerCase().contains('live') ?? false);

    DateTime? batchStart;
    final rawBatchStart = json['batch_start_date']?.toString() ??
        json['batch_start']?.toString() ??
        json['start_date']?.toString();
    if (rawBatchStart != null && rawBatchStart.isNotEmpty) {
      batchStart = DateTime.tryParse(rawBatchStart);
    }

    DateTime? batchEnd;
    final rawBatchEnd = json['batch_end_date']?.toString() ??
        json['batch_end']?.toString() ??
        json['end_date']?.toString();
    if (rawBatchEnd != null && rawBatchEnd.isNotEmpty) {
      batchEnd = DateTime.tryParse(rawBatchEnd);
    }

    DateTime? regDeadline;
    final rawDeadline = json['registration_deadline']?.toString() ??
        json['deadline']?.toString() ??
        json['cutoff_date']?.toString();
    if (rawDeadline != null && rawDeadline.isNotEmpty) {
      regDeadline = DateTime.tryParse(rawDeadline);
    }

    final int durationDays = (json['course_duration_days'] as num?)?.toInt() ??
        (json['duration_days'] as num?)?.toInt() ??
        int.tryParse(json['days']?.toString() ?? '15') ??
        15;

    final String meetingLinkUrl = json['meeting_link']?.toString() ??
        json['zoom_link']?.toString() ??
        json['meet_link']?.toString() ??
        '';

    return CourseModel(
      id: json['id']?.toString() ??
          json['course_id']?.toString() ??
          json['cid']?.toString() ??
          '',
      title: json['title']?.toString() ??
          json['course_title']?.toString() ??
          json['name']?.toString() ??
          json['course_name']?.toString() ??
          '',
      description: json['description']?.toString() ??
          json['course_description']?.toString() ??
          json['details']?.toString() ??
          json['overview']?.toString() ??
          '',
      category: json['category']?.toString() ??
          json['category_name']?.toString() ??
          json['cat_name']?.toString() ??
          'General',
      subCategory: json['subCategory']?.toString() ??
          json['sub_category']?.toString() ??
          json['subcategory']?.toString(),
      imageUrl: _formatUrl(rawImageUrl),
      trailerUrl: _formatUrl(rawTrailerUrl),
      price: (json['price'] as num?)?.toDouble() ??
          (json['course_price'] as num?)?.toDouble() ??
          double.tryParse(json['price']?.toString() ?? '') ??
          double.tryParse(json['course_price']?.toString() ?? '') ??
          0.0,
      duration: json['duration']?.toString() ??
          json['course_duration']?.toString() ??
          json['hours']?.toString() ??
          'Self-Paced',
      rating: (json['rating'] as num?)?.toDouble() ??
          (json['avg_rating'] as num?)?.toDouble() ??
          double.tryParse(json['rating']?.toString() ?? '') ??
          5.0,
      modulesCount: (json['modulesCount'] as num?)?.toInt() ??
          (json['modules_count'] as num?)?.toInt() ??
          (json['modules'] as num?)?.toInt() ??
          int.tryParse(json['modules_count']?.toString() ?? '') ??
          int.tryParse(json['modules']?.toString() ?? '') ??
          (parsedModules.isNotEmpty ? parsedModules.length : 0),
      learnings: parsedLearnings,
      modulesList: parsedModules,
      createdAt: parsedCreatedAt,
      isLive: isLiveFlag,
      batchStartDate: batchStart,
      batchEndDate: batchEnd,
      registrationDeadline: regDeadline,
      courseDurationDays: durationDays,
      meetingLink: meetingLinkUrl,
      outcomes: parsedLearnings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'imageUrl': imageUrl,
      'trailerUrl': trailerUrl,
      'price': price,
      'duration': duration,
      'rating': rating,
      'modulesCount': modulesCount,
      'learnings': learnings,
    };
  }
}
