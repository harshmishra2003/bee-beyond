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

    // Default E-Commerce & Membership Books Catalogue
    return const [
      BookItem(
        id: 'b_1',
        title: '38 Bach Flower Remedies Complete Clinical Handbook',
        author: 'Dr. Edward Bach & Bee Beyonnd Vault',
        category: 'Bach Flower Therapy',
        size: '4.2 MB',
        totalPages: 48,
        rating: 4.9,
        description: 'Comprehensive practitioner reference covering all 38 remedies, emotional diagnostic charts, dosage guidelines, and real case studies.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        samplePagesContent: ['Sample Page 1: Rescue Remedy Essentials', 'Sample Page 2: Emotional State Matrix'],
        accessType: 'paid',
        price: 299.0,
        originalPrice: 499.0,
        isPurchased: false,
      ),
      BookItem(
        id: 'b_2',
        title: 'Master Vastu Shastra & Directional Energy Alignment',
        author: 'Bee Beyonnd Vastu Experts',
        category: 'Vastu Shastra',
        size: '6.8 MB',
        totalPages: 65,
        rating: 5.0,
        description: 'Illustrated guide to directional energies, remedy placement, office and home layout corrections without demolition.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        samplePagesContent: ['Sample Page 1: North-East Sacred Zone', 'Sample Page 2: Pyra Vastu Remedies'],
        accessType: 'membership',
        price: 0.0,
        isPurchased: false,
      ),
      BookItem(
        id: 'b_3',
        title: 'Ayurveda Fundamentals & Daily Rituals Guidebook',
        author: 'Bee Beyonnd Ayurvedic Doctors',
        category: 'Ayurveda',
        size: '3.1 MB',
        totalPages: 32,
        rating: 4.8,
        description: 'Free introduction to Vata, Pitta, and Kapha dosha self-analysis, herbal teas, seasonal cleansing, and daily Dinacharya habits.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        samplePagesContent: ['Sample Page 1: Dosha Analysis Chart'],
        accessType: 'free',
        price: 0.0,
        isPurchased: false,
      ),
      BookItem(
        id: 'b_4',
        title: 'Scientific Graphology & Handwriting Analysis Manual',
        author: 'Bee Beyonnd Mind Institute',
        category: 'Graphology',
        size: '5.5 MB',
        totalPages: 52,
        rating: 4.9,
        description: 'Professional handbook on strokes, margins, slants, signatures, personality profiling, and psychological traits analysis.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        samplePagesContent: ['Sample Page 1: Signature Analysis Secrets'],
        accessType: 'paid',
        price: 499.0,
        originalPrice: 999.0,
        isPurchased: false,
      ),
      BookItem(
        id: 'b_5',
        title: 'Alternative Drugless Remedies & Natural Healing Vault',
        author: 'Bee Beyonnd Health Vault',
        category: 'Drugless Cure',
        size: '2.8 MB',
        totalPages: 38,
        rating: 4.7,
        description: 'Free handbook on acupressure points, mudra therapy, breathwork techniques, and natural home remedies for common ailments.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        samplePagesContent: ['Sample Page 1: Healing Mudras Chart'],
        accessType: 'free',
        price: 0.0,
        isPurchased: false,
      ),
    ];
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
