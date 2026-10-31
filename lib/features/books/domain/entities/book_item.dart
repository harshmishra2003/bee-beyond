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
  final double mrp;
  final double rating;
  final int pages;
  final bool isPaid;
  final bool isPurchased;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.pdfUrl,
    required this.coverUrl,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.pages,
    required this.isPaid,
    this.isPurchased = false,
  });

  BookItem copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    String? description,
    String? pdfUrl,
    String? coverUrl,
    double? price,
    double? mrp,
    double? rating,
    int? pages,
    bool? isPaid,
    bool? isPurchased,
  }) {
    return BookItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      description: description ?? this.description,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      rating: rating ?? this.rating,
      pages: pages ?? this.pages,
      isPaid: isPaid ?? this.isPaid,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  factory BookItem.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'] ?? json['selling_price'] ?? json['amount'];
    double sellingPrice = 0.0;
    if (rawPrice is num) {
      sellingPrice = rawPrice.toDouble();
    } else if (rawPrice != null) {
      sellingPrice = double.tryParse(rawPrice.toString()) ?? 0.0;
    }

    final rawMrp = json['mrp'] ?? json['original_price'] ?? json['list_price'];
    double listMrp = 0.0;
    if (rawMrp is num) {
      listMrp = rawMrp.toDouble();
    } else if (rawMrp != null) {
      listMrp = double.tryParse(rawMrp.toString()) ?? 0.0;
    }

    final paid = json['isPaid'] == true || json['is_paid'] == 1 || sellingPrice > 0;

    return BookItem(
      id: json['id']?.toString() ?? 'bk_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Ayurvedic Study Handbook',
      author: json['author']?.toString() ?? 'Acharya Devraj',
      category: json['category']?.toString() ?? 'Bach Flower',
      description: json['description']?.toString() ?? 'Official digital handbook and reference diagnostic manual.',
      pdfUrl: json['pdfUrl']?.toString() ??
          json['pdf_url']?.toString() ??
          json['file']?.toString() ??
          'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      coverUrl: json['coverUrl']?.toString() ?? json['image']?.toString() ?? '',
      price: sellingPrice,
      mrp: listMrp > 0 ? listMrp : (sellingPrice > 0 ? sellingPrice * 1.4 : 0.0),
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      pages: int.tryParse(json['pages']?.toString() ?? '120') ?? 120,
      isPaid: paid,
      isPurchased: json['isPurchased'] == true || json['is_purchased'] == 1,
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
        mrp,
        rating,
        pages,
        isPaid,
        isPurchased,
      ];
}
