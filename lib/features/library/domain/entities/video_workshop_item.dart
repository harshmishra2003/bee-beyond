import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';

class VideoWorkshopItem extends Equatable {
  final String id;
  final String title;
  final String category;
  final String instructor;
  final String duration;
  final String views;
  final double rating;
  final String thumbnailUrl;
  final String videoUrl;
  final String description;
  final List<String> takeaways;
  final bool isFeatured;

  const VideoWorkshopItem({
    required this.id,
    required this.title,
    required this.category,
    this.instructor = 'Bee Beyonnd Academy',
    required this.duration,
    this.views = '1.2k Views',
    this.rating = 5.0,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.description,
    this.takeaways = const [],
    this.isFeatured = false,
  });

  static String _formatUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    String trimmed = url.trim();

    if (trimmed.contains('localhost')) {
      trimmed = trimmed.replaceAll('http://localhost', 'https://metricstestingapp.xyz');
      trimmed = trimmed.replaceAll('https://localhost', 'https://metricstestingapp.xyz');
    }
    if (trimmed.contains('127.0.0.1')) {
      trimmed = trimmed.replaceAll('http://127.0.0.1', 'https://metricstestingapp.xyz');
      trimmed = trimmed.replaceAll('https://127.0.0.1', 'https://metricstestingapp.xyz');
    }

    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('assets/')) {
      return trimmed;
    }

    String baseUrl = ApiEndpoints.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }
    return '$baseUrl/$trimmed';
  }

  factory VideoWorkshopItem.fromJson(Map<String, dynamic> json) {
    final rawVideoUrl = json['video_url']?.toString() ??
        json['videoUrl']?.toString() ??
        json['url']?.toString() ??
        json['media_url']?.toString() ??
        json['file_url']?.toString() ??
        '';

    final videoUrl = _formatUrl(rawVideoUrl);

    final rawThumbUrl = json['thumbnailUrl']?.toString() ??
        json['thumbnail_url']?.toString() ??
        json['thumbnail']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        '';

    final thumbnailUrl = _formatUrl(rawThumbUrl);

    return VideoWorkshopItem(
      id: json['id']?.toString() ?? json['video_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Guided Workshop Video',
      category: json['category']?.toString() ?? json['category_name']?.toString() ?? 'General',
      instructor: json['instructor']?.toString() ??
          json['instructor_name']?.toString() ??
          'Bee Beyonnd Academy',
      duration: json['duration']?.toString() ?? '05:00',
      views: json['views']?.toString() ?? '1.2k Views',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      description: json['description']?.toString() ?? '',
      takeaways: (json['takeaways'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [
            'Master core principles & daily practical application',
            'Certified practitioner tips & holistic guidance',
          ],
      isFeatured: json['isFeatured'] == true ||
          json['is_featured'] == 1 ||
          json['is_featured'] == '1' ||
          json['status'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'instructor': instructor,
      'duration': duration,
      'views': views,
      'rating': rating,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'description': description,
      'takeaways': takeaways,
      'isFeatured': isFeatured,
    };
  }

  String get categoryBadge {
    switch (category.toLowerCase()) {
      case 'bach flower':
        return '🌿 BACH FLOWER';
      case 'ayurveda':
      case 'ayurvedic upchar':
        return '🎓 AYURVEDA';
      case 'vastu shastra':
        return '🔮 VASTU SHASTRA';
      case 'cricket':
        return '🏏 WELLNESS SPORTS';
      case 'breathwork':
        return '🧘 BREATHWORK';
      case 'meditation':
        return '✨ MEDITATION';
      default:
        return '📹 WORKSHOP';
    }
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'bach flower':
      case 'cricket':
        return const Color(0xFF059669);
      case 'ayurveda':
      case 'ayurvedic upchar':
        return const Color(0xFF4338CA);
      case 'vastu shastra':
        return const Color(0xFFD97706);
      case 'breathwork':
        return const Color(0xFF0288D1);
      case 'meditation':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF4338CA);
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        instructor,
        duration,
        views,
        rating,
        thumbnailUrl,
        videoUrl,
        description,
        takeaways,
        isFeatured,
      ];
}
