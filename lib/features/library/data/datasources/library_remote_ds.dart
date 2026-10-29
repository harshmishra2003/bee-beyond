import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/book_item.dart';
import '../../domain/entities/healing_audio_track.dart';
import '../../domain/entities/video_workshop_item.dart';

abstract class LibraryRemoteDataSource {
  Future<List<BookItem>> getBooksAndMaterials();
  Future<BookItem> getBookDetail(String id);
  Future<List<HealingAudioTrack>> getAudioTracks();
  Future<List<VideoWorkshopItem>> getVideoWorkshops();
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final DioClient? _dioClient;

  LibraryRemoteDataSourceImpl([this._dioClient]);

  @override
  Future<List<BookItem>> getBooksAndMaterials() async {
    final dio = _dioClient?.instance ??
        Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

    final candidateEndpoints = [
      ApiEndpoints.books, // '/library/books'
      '/books.php',
      '/library/books.php',
      '/books',
    ];

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await dio.get(
          endpoint,
          queryParameters: {
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          final List<dynamic> list = rawData is Map
              ? (rawData['data'] ?? rawData['books'] ?? rawData['materials'] ?? rawData['items'] ?? [])
              : (rawData is List ? rawData : []);

          if (list.isNotEmpty) {
            return list
                .map((json) => BookItem.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<BookItem> getBookDetail(String id) async {
    final dio = _dioClient?.instance ??
        Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

    final candidateEndpoints = [
      '${ApiEndpoints.bookDetail}?id=$id', // '/book_details.php?id=1'
      '/book_details.php?id=$id',
      '/library/book_details.php?id=$id',
    ];

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await dio.get(
          endpoint,
          queryParameters: {
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          if (rawData is Map) {
            final Map<String, dynamic> data = (rawData['data'] is Map)
                ? Map<String, dynamic>.from(rawData['data'] as Map)
                : Map<String, dynamic>.from(rawData);

            return BookItem.fromJson(data);
          }
        }
      } catch (_) {}
    }

    throw Exception('Could not fetch book details for ID: $id');
  }

  @override
  Future<List<HealingAudioTrack>> getAudioTracks() async {
    final dio = _dioClient?.instance ??
        Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Cache-Control': 'no-cache, no-store, must-revalidate',
            },
          ),
        );

    final candidateEndpoints = [
      ApiEndpoints.music, // '/music.php'
      'https://metricstestingapp.xyz/api/music.php',
      '/music.php',
      '/library/music',
      '/audio.php',
      '/tracks.php',
    ];

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await dio.get(
          endpoint,
          queryParameters: {
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          final List<dynamic> list = rawData is Map
              ? (rawData['data'] ?? rawData['tracks'] ?? rawData['music'] ?? rawData['items'] ?? [])
              : (rawData is List ? rawData : []);

          if (list.isNotEmpty) {
            return list
                .map((json) => HealingAudioTrack.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }

    return [];
  }

  @override
  Future<List<VideoWorkshopItem>> getVideoWorkshops() async {
    final dio = _dioClient?.instance ??
        Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Cache-Control': 'no-cache, no-store, must-revalidate',
            },
          ),
        );

    final candidateEndpoints = [
      ApiEndpoints.video, // '/videos.php'
      'https://metricstestingapp.xyz/api/videos.php',
      '/videos.php',
      '/video.php',
      '/workshops.php',
      '/library/video',
    ];

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await dio.get(
          endpoint,
          queryParameters: {
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          final List<dynamic> list = rawData is Map
              ? (rawData['data'] ?? rawData['videos'] ?? rawData['workshops'] ?? rawData['items'] ?? [])
              : (rawData is List ? rawData : []);

          if (list.isNotEmpty) {
            return list
                .map((json) => VideoWorkshopItem.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }
}
