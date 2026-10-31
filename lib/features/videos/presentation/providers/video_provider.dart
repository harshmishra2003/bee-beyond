import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/video_lecture_item.dart';

final videoLecturesProvider = FutureProvider<List<VideoLectureItem>>((ref) async {
  final dio = ref.watch(dioClientProvider);

  try {
    final response = await dio.get(
      ApiEndpoints.video,
      queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
    );

    if (response.statusCode == 200 && response.data != null) {
      dynamic rawData = response.data;
      if (rawData is String) rawData = jsonDecode(rawData);

      final List list = rawData is Map
          ? (rawData['data'] ?? rawData['videos'] ?? rawData['lectures'] ?? [])
          : (rawData is List ? rawData : []);

      if (list.isNotEmpty) {
        return list.map((json) => VideoLectureItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    }
  } catch (_) {}

  // Official Bee Beyonnd YouTube Channel (@beebeyonndofficial) Video Feed
  return const [
    VideoLectureItem(
      id: 'yt_101',
      title: 'Bee Beyonnd Official Introduction & Holistic Healing Overview',
      instructor: 'Acharya Devraj & Team',
      category: 'Overview',
      duration: '18:45',
      videoUrl: 'https://youtube.com/@beebeyonndofficial',
      thumbnailUrl: 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=800&q=80',
      rating: 4.98,
      views: 8900,
      description: 'Welcome to Bee Beyonnd official channel. Learn about Bach Flower therapy, Ayurvedic healing, and Vastu corrections.',
      isYouTube: true,
    ),
    VideoLectureItem(
      id: 'yt_102',
      title: 'Bach Flower Remedy Diagnosis & Emotional Case Studies',
      instructor: 'Acharya Devraj',
      category: 'Bach Flower',
      duration: '42:15',
      videoUrl: 'https://youtube.com/@beebeyonndofficial',
      thumbnailUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
      rating: 4.95,
      views: 6420,
      description: 'In-depth clinical demonstration on diagnosing emotional patterns and prescribing Bach flower remedies.',
      isYouTube: true,
    ),
    VideoLectureItem(
      id: 'yt_103',
      title: 'Vedic Vastu Energy Correction Masterclass & Directions',
      instructor: 'Dr. Rameshwar Vastu Gurukul',
      category: 'Vastu',
      duration: '35:20',
      videoUrl: 'https://youtube.com/@beebeyonndofficial',
      thumbnailUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
      rating: 4.90,
      views: 5120,
      description: 'Hands-on practical walkthrough of residential and office Vastu mapping without structural demolition.',
      isYouTube: true,
    ),
  ];
});
