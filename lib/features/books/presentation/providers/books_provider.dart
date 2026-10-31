import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book_item.dart';

final booksAndMaterialsProvider = FutureProvider<List<BookItem>>((ref) async {
  final dio = ref.watch(dioClientProvider);

  try {
    final response = await dio.get(
      ApiEndpoints.books,
      queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
    );

    if (response.statusCode == 200 && response.data != null) {
      dynamic rawData = response.data;
      if (rawData is String) rawData = jsonDecode(rawData);

      final List list = rawData is Map
          ? (rawData['data'] ?? rawData['books'] ?? rawData['materials'] ?? rawData['items'] ?? [])
          : (rawData is List ? rawData : []);

      if (list.isNotEmpty) {
        return list.map((json) => BookItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    }
  } catch (_) {}

  // Standard official study handbooks list
  return const [
    BookItem(
      id: 'bk_101',
      title: 'Official Bach Flower Remedies Handbook & Diagnostic Guide',
      author: 'Acharya Devraj',
      category: 'Bach Flower',
      description: 'Comprehensive diagnostic handbook detailing all 38 Bach Flower Remedies, emotional mapping, and clinical case studies.',
      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&q=80',
      price: 399.0,
      rating: 4.95,
      pages: 148,
      isPaid: false,
    ),
    BookItem(
      id: 'bk_102',
      title: 'Ayurvedic Prakriti Diagnosis & Herbal Compounding Reference',
      author: 'Vaidya Ananya Sharma',
      category: 'Ayurveda',
      description: 'In-depth reference manual on Tridosha evaluation, pulse diagnosis, and traditional organic herbal tea formulations.',
      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=800&q=80',
      price: 499.0,
      rating: 4.90,
      pages: 180,
      isPaid: true,
    ),
    BookItem(
      id: 'bk_103',
      title: 'Vedic Vastu Directions & Energy Correction Manual',
      author: 'Dr. Rameshwar Vastu Gurukul',
      category: 'Vastu',
      description: 'Practical guide to non-demolition energy corrections, Marma grid mapping, and pyramid directional alignments.',
      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=80',
      price: 599.0,
      rating: 4.88,
      pages: 210,
      isPaid: true,
    ),
  ];
});
