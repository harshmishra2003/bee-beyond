import 'package:equatable/equatable.dart';

class BookItem extends Equatable {
  final String id;
  final String title;
  final String author;
  final String category;
  final String description;
  final String pdfUrl;
  final String coverUrl;
  final double price;
  final double rating;
  final int pages;
  final bool isPaid;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.pdfUrl,
    required this.coverUrl,
    required this.price,
    required this.rating,
    required this.pages,
    required this.isPaid,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      id: json['id']?.toString() ?? 'bk_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Ayurvedic Study Guide & Handbook',
      author: json['author']?.toString() ?? 'Acharya Devraj',
      category: json['category']?.toString() ?? 'Bach Flower & Ayurveda',
      description: json['description']?.toString() ?? 'Comprehensive reference handbook containing remedies, diagnostic charts, and clinical protocols.',
      pdfUrl: json['pdfUrl']?.toString() ??
          json['pdf_url']?.toString() ??
          json['pdf']?.toString() ??
          json['file_url']?.toString() ??
          json['file']?.toString() ??
          json['book_url']?.toString() ??
          json['book']?.toString() ??
          json['document_url']?.toString() ??
          json['doc_url']?.toString() ??
          json['url']?.toString() ??
          json['link']?.toString() ??
          'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      coverUrl: json['coverUrl']?.toString() ?? json['image']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '399') ?? 399.0,
      rating: double.tryParse(json['rating']?.toString() ?? '4.9') ?? 4.9,
      pages: int.tryParse(json['pages']?.toString() ?? '120') ?? 120,
      isPaid: json['isPaid'] == true || json['is_paid'] == 1,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        category,
        description,
        pdfUrl,
        coverUrl,
        price,
        rating,
        pages,
        isPaid,
      ];
}
