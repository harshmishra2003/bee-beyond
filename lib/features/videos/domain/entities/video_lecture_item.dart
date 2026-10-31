import 'package:equatable/equatable.dart';

class VideoLectureItem extends Equatable {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final String duration;
  final String videoUrl;
  final String thumbnailUrl;
  final double rating;
  final int views;
  final String description;
  final bool isYouTube;

  const VideoLectureItem({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.duration,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.rating,
    required this.views,
    required this.description,
    this.isYouTube = true,
  });

  static const String youtubeChannelUrl = 'https://youtube.com/@beebeyonndofficial';

  String? get youtubeVideoId {
    if (videoUrl.contains('youtu.be/')) {
      return videoUrl.split('youtu.be/').last.split('?').first;
    } else if (videoUrl.contains('youtube.com/watch?v=')) {
      return videoUrl.split('v=').last.split('&').first;
    } else if (videoUrl.contains('youtube.com/embed/')) {
      return videoUrl.split('embed/').last.split('?').first;
    }
    return null;
  }

  String get effectiveThumbnailUrl {
    if (thumbnailUrl.isNotEmpty && thumbnailUrl.startsWith('http')) {
      return thumbnailUrl;
    }
    final ytId = youtubeVideoId;
    if (ytId != null && ytId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
    }
    return 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=800&q=80';
  }

  factory VideoLectureItem.fromJson(Map<String, dynamic> json) {
    final vUrl = json['videoUrl']?.toString() ?? json['video_url']?.toString() ?? 'https://youtube.com/@beebeyonndofficial';
    final isYt = vUrl.contains('youtube.com') || vUrl.contains('youtu.be');

    return VideoLectureItem(
      id: json['id']?.toString() ?? 'vid_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Bee Beyonnd Official Video Lecture',
      instructor: json['instructor']?.toString() ?? 'Acharya Devraj',
      category: json['category']?.toString() ?? 'Ayurveda & Wellness',
      duration: json['duration']?.toString() ?? '25:00',
      videoUrl: vUrl,
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? json['image']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '4.9') ?? 4.9,
      views: int.tryParse(json['views']?.toString() ?? '3200') ?? 3200,
      description: json['description']?.toString() ?? 'Official video from Bee Beyonnd YouTube Channel (@beebeyonndofficial).',
      isYouTube: isYt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        instructor,
        category,
        duration,
        videoUrl,
        thumbnailUrl,
        rating,
        views,
        description,
        isYouTube,
      ];
}
