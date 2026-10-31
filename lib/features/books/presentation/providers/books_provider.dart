import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book_item.dart';

class PurchasedBooksNotifier extends StateNotifier<Set<String>> {
  PurchasedBooksNotifier() : super({});

  void markPurchased(String bookId) {
    state = {...state, bookId};
  }

  bool isPurchased(String bookId) {
    return state.contains(bookId);
  }
}

final purchasedBooksProvider = StateNotifierProvider<PurchasedBooksNotifier, Set<String>>((ref) {
  return PurchasedBooksNotifier();
});

final booksAndMaterialsProvider = FutureProvider<List<BookItem>>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final purchasedSet = ref.watch(purchasedBooksProvider);

  List<BookItem> booksList = [];

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
        booksList = list.map((json) => BookItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    }
  } catch (_) {}

  if (booksList.isEmpty) {
    // Official Bee Beyonnd Digital Handbooks & E-Books Collection
    booksList = const [
      // Section: Ebooks for you
      BookItem(
        id: 'bk_101',
        title: 'Jivan Vikas Ke Sopan / Jivan Vikas Guide',
        author: 'Swami Swarupanand',
        category: 'Ebooks for you',
        description: 'A transformative spiritual guide on self-realization, inner peace, and personal growth protocols.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&q=80',
        price: 59.00,
        mrp: 99.00,
        rating: 5.0,
        pages: 112,
        isPaid: true,
      ),
      BookItem(
        id: 'bk_102',
        title: 'Foundations of Software Science & Computation',
        author: 'Christel Baier & Ugo Dal Lago',
        category: 'Ebooks for you',
        description: 'Comprehensive academic reference text on formal methods, logical frameworks, and computational structures.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=800&q=80',
        price: 0.0,
        mrp: 0.0,
        rating: 5.0,
        pages: 340,
        isPaid: false,
      ),
      BookItem(
        id: 'bk_103',
        title: 'Abundance: The Future Is Better Than You Think',
        author: 'Peter H. Diamandis',
        category: 'Ebooks for you',
        description: 'Documenting how exponential technologies and human innovation are solving global challenges.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=80',
        price: 504.45,
        mrp: 1008.90,
        rating: 4.8,
        pages: 280,
        isPaid: true,
      ),
      BookItem(
        id: 'bk_104',
        title: 'Shabar Mantra Sangrah Bhag 14 (Mahakali Siddhi)',
        author: 'Book 4 Gurukul Edition',
        category: 'Ebooks for you',
        description: 'Authentic classical Shabar Tantric collection, Mahakali sadhana charts, and protective stotras.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=800&q=80',
        price: 265.15,
        mrp: 378.78,
        rating: 4.9,
        pages: 160,
        isPaid: true,
      ),
      BookItem(
        id: 'bk_105',
        title: 'Dhyan: Kya, Kyon aur Kaise (Patanjali Yoga Sutra)',
        author: 'Vastu Shastra Gurukul',
        category: 'Ebooks for you',
        description: 'Practical meditation walkthroughs based on Patanjali Ashtanga Yoga for mental clarity.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
        price: 195.76,
        mrp: 279.66,
        rating: 5.0,
        pages: 145,
        isPaid: true,
      ),

      // Section: Top Selling Handbooks
      BookItem(
        id: 'bk_201',
        title: 'Bach Flower Remedies Clinical Companion & Diagnosis',
        author: 'Acharya Devraj',
        category: 'Top selling',
        description: 'Diagnostic handbook mapping all 38 Bach Flower Remedies with real patient case studies and dosage charts.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&q=80',
        price: 351.05,
        mrp: 702.10,
        rating: 4.95,
        pages: 185,
        isPaid: true,
      ),
      BookItem(
        id: 'bk_202',
        title: 'Fermat\'s Enigma: The Epic Quest to Solve Problem',
        author: 'Simon Singh',
        category: 'Top selling',
        description: 'The national bestseller documenting the 350-year mathematical mystery solved by Andrew Wiles.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=800&q=80',
        price: 453.44,
        mrp: 650.00,
        rating: 4.9,
        pages: 220,
        isPaid: true,
      ),
      BookItem(
        id: 'bk_203',
        title: 'Basic Electronics: Solid State Principles',
        author: 'S. Chand Series',
        category: 'Top selling',
        description: 'Standard foundational textbook on semiconductor physics, circuit design, and solid state electronics.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=80',
        price: 587.05,
        mrp: 850.00,
        rating: 4.7,
        pages: 310,
        isPaid: true,
      ),

      // Section: Ayurvedic & Healing Guides
      BookItem(
        id: 'bk_301',
        title: 'Gita Ka Marma / Secrets of Bhagavad Gita',
        author: 'Swami Shivatmanand',
        category: 'Ayurvedic & Healing',
        description: 'Spiritual commentary explaining Karma, Bhakti, and Jnana Yoga in daily life.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=800&q=80',
        price: 35.40,
        mrp: 60.00,
        rating: 5.0,
        pages: 96,
        isPaid: true,
      ),
      BookItem(
        id: 'bk_302',
        title: 'Jeevan Janam Ke Uddeshya Ki Talash',
        author: 'Sirshree Practitioner',
        category: 'Ayurvedic & Healing',
        description: 'Discovering life purpose, spiritual awakening, and inner harmony.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
        price: 50.00,
        mrp: 80.00,
        rating: 5.0,
        pages: 104,
        isPaid: true,
      ),
      BookItem(
        id: 'bk_303',
        title: 'Rich Dad Poor Dad - 20th Anniversary Edition',
        author: 'Robert T. Kiyosaki',
        category: 'Ayurvedic & Healing',
        description: 'Personal finance classic on asset building, financial literacy, and mindsets.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&q=80',
        price: 173.46,
        mrp: 247.80,
        rating: 4.9,
        pages: 240,
        isPaid: true,
      ),

      // Section: Vastu Shastra Manuals
      BookItem(
        id: 'bk_401',
        title: 'Vedic Vastu Directions & Elemental Balance Manual',
        author: 'Dr. Rameshwar Vastu Gurukul',
        category: 'Vastu Manuals',
        description: 'Non-demolition remedies, directional compass mapping, and Marma point energy balancing.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
        price: 289.89,
        mrp: 450.00,
        rating: 4.9,
        pages: 195,
        isPaid: true,
      ),
      BookItem(
        id: 'bk_402',
        title: 'Katha Chanakya: Lessons in Wisdom and Strategy',
        author: 'Radhakrishnan Pillai',
        category: 'Vastu Manuals',
        description: 'Chanakya Neeti principles applied to modern leadership, management, and life decisions.',
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
        coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=800&q=80',
        price: 185.00,
        mrp: 299.00,
        rating: 4.85,
        pages: 168,
        isPaid: true,
      ),
    ];
  }

  // Attach purchase status dynamically
  return booksList.map((book) {
    if (purchasedSet.contains(book.id)) {
      return book.copyWith(isPurchased: true);
    }
    return book;
  }).toList();
});
