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
  });

  static String _formatUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('assets/')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return 'https://metricstestingapp.xyz$trimmed';
    }
    if (trimmed.startsWith('uploads/') || trimmed.startsWith('admin/')) {
      return 'https://metricstestingapp.xyz/$trimmed';
    }
    return 'https://metricstestingapp.xyz/api/$trimmed';
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
    final rawLearnings = json['learnings'] ??
        json['outcomes'] ??
        json['what_you_will_learn'] ??
        json['highlights'] ??
        json['key_points'] ??
        json['points'];

    if (rawLearnings is List) {
      parsedLearnings = rawLearnings.map((e) => e.toString()).toList();
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
      parsedModules = rawModules.map((item) {
        if (item is Map<String, dynamic>) {
          final media = _formatUrl(
            item['media_url']?.toString() ??
                item['mediaUrl']?.toString() ??
                item['file_url']?.toString() ??
                item['video_url']?.toString() ??
                item['pdf_url']?.toString() ??
                item['url']?.toString() ??
                item['file']?.toString() ??
                '',
          );

          String detectedType = item['type']?.toString().toLowerCase() ?? '';
          if (detectedType.isEmpty) {
            if (media.toLowerCase().contains('.pdf') || media.contains('/pdf')) {
              detectedType = 'pdf';
            } else {
              detectedType = 'video';
            }
          }

          return ModuleItemEntity(
            id: item['id']?.toString() ?? '',
            title: item['title']?.toString() ?? item['name']?.toString() ?? 'Module Lecture',
            type: detectedType,
            mediaUrl: media,
            durationOrSize: item['duration']?.toString() ??
                item['size']?.toString() ??
                (detectedType == 'pdf' ? 'PDF Study Guide' : 'Video Lecture'),
          );
        }
        return ModuleItemEntity(
          id: '',
          title: item.toString(),
          type: 'video',
          mediaUrl: '',
          durationOrSize: 'Video Lecture',
        );
      }).toList();
    }

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
          (parsedModules.isNotEmpty ? parsedModules.length : 10),
      learnings: parsedLearnings,
      modulesList: parsedModules,
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
