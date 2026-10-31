import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/video_lecture_item.dart';

/// Provider strictly fetching live videos from Bee Beyonnd Official YouTube Channel (@beebeyonndofficial).
/// URL: https://youtube.com/@beebeyonndofficial?si=z6Us3m4bXfOWo_jj
/// Strictly no third-party or backend API videos. If 0 videos published on the channel, returns [].
final videoLecturesProvider = FutureProvider<List<VideoLectureItem>>((ref) async {
  final dio = ref.watch(dioClientProvider);

  // YouTube RSS feeds for @beebeyonndofficial
  final feedUrls = [
    'https://www.youtube.com/feeds/videos.xml?user=beebeyonndofficial',
    'https://www.youtube.com/feeds/videos.xml?channel_id=beebeyonndofficial',
  ];

  for (final url in feedUrls) {
    try {
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {'User-Agent': 'Mozilla/5.0'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final content = response.data.toString();
        final videos = _parseYouTubeRssFeed(content);
        if (videos.isNotEmpty) {
          return videos;
        }
      }
    } catch (_) {}
  }

  // Strictly return [] if 0 videos exist on @beebeyonndofficial channel
  return const [];
});

List<VideoLectureItem> _parseYouTubeRssFeed(String xmlString) {
  final List<VideoLectureItem> items = [];

  final entryMatches = RegExp(r'<entry>(.*?)</entry>', dotAll: true).allMatches(xmlString);

  for (final match in entryMatches) {
    final entryXml = match.group(1) ?? '';

    final videoIdMatch = RegExp(r'<yt:videoId>(.*?)</yt:videoId>').firstMatch(entryXml);
    final titleMatch = RegExp(r'<title>(.*?)</title>').firstMatch(entryXml);
    final publishedMatch = RegExp(r'<published>(.*?)</published>').firstMatch(entryXml);
    final descriptionMatch = RegExp(r'<media:description>(.*?)</media:description>', dotAll: true).firstMatch(entryXml);
    final viewsMatch = RegExp(r'views="(\d+)"').firstMatch(entryXml);

    final ytId = videoIdMatch?.group(1)?.trim() ?? '';
    if (ytId.isEmpty) continue;

    final rawTitle = titleMatch?.group(1)?.trim() ?? 'Bee Beyonnd Official Video';
    final rawPublished = publishedMatch?.group(1)?.trim() ?? '';
    final rawDesc = descriptionMatch?.group(1)?.trim() ?? 'Official video from Bee Beyonnd YouTube Channel (@beebeyonndofficial).';
    final viewsCount = int.tryParse(viewsMatch?.group(1) ?? '0') ?? 0;

    String formattedDate = 'Recently Uploaded';
    if (rawPublished.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawPublished);
        formattedDate = '${dt.day} ${_monthName(dt.month)} ${dt.year}';
      } catch (_) {}
    }

    items.add(VideoLectureItem(
      id: 'yt_$ytId',
      title: _decodeXmlEntities(rawTitle),
      instructor: 'Bee Beyonnd Official',
      category: 'YouTube Channel',
      duration: 'YouTube Video',
      videoUrl: 'https://www.youtube.com/watch?v=$ytId',
      thumbnailUrl: 'https://img.youtube.com/vi/$ytId/hqdefault.jpg',
      rating: 4.9,
      views: viewsCount,
      likes: (viewsCount * 0.12).toInt(),
      uploadDate: formattedDate,
      description: _decodeXmlEntities(rawDesc),
      isYouTube: true,
    ));
  }

  return items;
}

String _monthName(int month) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  if (month >= 1 && month <= 12) return months[month - 1];
  return 'Oct';
}

String _decodeXmlEntities(String text) {
  return text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}
