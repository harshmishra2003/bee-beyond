import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BookItem extends Equatable {
  final String id;
  final String title;
  final String author;
  final String category;
  final String size;
  final int totalPages;
  final double rating;
  final String description;
  final String pdfUrl;
  final List<String> samplePagesContent;

  // DYNAMIC E-COMMERCE & ACCESS FIELDS
  final String accessType; // 'free', 'paid', 'membership'
  final double price;
  final double? originalPrice;
  final bool isPurchased;
  final String coverImageUrl;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.size,
    required this.totalPages,
    required this.rating,
    required this.description,
    this.pdfUrl = '',
    required this.samplePagesContent,
    this.accessType = 'free',
    this.price = 0.0,
    this.originalPrice,
    this.isPurchased = false,
    this.coverImageUrl = '',
  });

  int get discountPercent {
    if (originalPrice != null && originalPrice! > price && originalPrice! > 0) {
      return (((originalPrice! - price) / originalPrice!) * 100).round();
    }
    return 0;
  }

  static String _formatUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('assets/')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return 'https://metricstestingapp.xyz$trimmed';
    }
    return 'https://metricstestingapp.xyz/$trimmed';
  }

  factory BookItem.fromJson(Map<String, dynamic> json) {
    final rawPdfUrl = json['pdf_url']?.toString() ??
        json['pdfUrl']?.toString() ??
        json['url']?.toString() ??
        json['file_url']?.toString() ??
        json['book_url']?.toString() ??
        json['download_url']?.toString() ??
        json['file']?.toString() ??
        '';

    final pdfUrlStr = _formatUrl(rawPdfUrl);

    final rawCoverUrl = json['cover_image']?.toString() ??
        json['coverUrl']?.toString() ??
        json['cover_url']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['cover']?.toString() ??
        json['poster']?.toString() ??
        '';

    final coverUrlStr = _formatUrl(rawCoverUrl);

    final rawAuthor = json['author']?.toString() ?? json['author_name']?.toString() ?? '';
    final authorStr = rawAuthor.trim().isNotEmpty ? rawAuthor.trim() : 'Bee Beyonnd Vault';

    final rawCategory = json['category']?.toString() ??
        json['subCategory']?.toString() ??
        json['category_name']?.toString() ??
        'General';

    // Parse Access Type ('free', 'paid', 'membership')
    final rawAccessType = json['access_type']?.toString() ??
        json['accessType']?.toString() ??
        json['access']?.toString() ??
        json['type']?.toString() ??
        '';

    String parsedAccessType = 'free';
    final lowerAccess = rawAccessType.toLowerCase();
    if (lowerAccess.contains('paid') || lowerAccess.contains('purchase') || lowerAccess.contains('buy')) {
      parsedAccessType = 'paid';
    } else if (lowerAccess.contains('member') || lowerAccess.contains('vip') || lowerAccess.contains('pass')) {
      parsedAccessType = 'membership';
    } else if (json['price'] != null && (json['price'] as num) > 0) {
      parsedAccessType = 'paid';
    }

    final priceVal = (json['price'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        double.tryParse(json['price']?.toString() ?? '0') ??
        0.0;

    final originalPriceVal = (json['original_price'] as num?)?.toDouble() ??
        (json['originalPrice'] as num?)?.toDouble() ??
        (json['mrp'] as num?)?.toDouble() ??
        double.tryParse(json['original_price']?.toString() ?? '');

    final isPurchasedVal = json['is_purchased'] == true ||
        json['isPurchased'] == true ||
        json['purchased'] == true ||
        json['has_purchased'] == true;

    return BookItem(
      id: json['id']?.toString() ?? json['book_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Study Book',
      author: authorStr,
      category: rawCategory,
      size: json['size']?.toString() ?? json['file_size']?.toString() ?? '2.5 MB',
      totalPages: (json['totalPages'] as num?)?.toInt() ??
          (json['total_pages'] as num?)?.toInt() ??
          int.tryParse(json['pages']?.toString() ?? '10') ??
          10,
      rating: (json['rating'] as num?)?.toDouble() ??
          double.tryParse(json['rating']?.toString() ?? '5.0') ??
          5.0,
      description: json['description']?.toString() ?? json['details']?.toString() ?? '',
      pdfUrl: pdfUrlStr,
      samplePagesContent: (json['samplePagesContent'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['sample_pages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      accessType: parsedAccessType,
      price: priceVal,
      originalPrice: originalPriceVal,
      isPurchased: isPurchasedVal,
      coverImageUrl: coverUrlStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'size': size,
      'totalPages': totalPages,
      'rating': rating,
      'description': description,
      'pdfUrl': pdfUrl,
      'samplePagesContent': samplePagesContent,
      'accessType': accessType,
      'price': price,
      'originalPrice': originalPrice,
      'isPurchased': isPurchased,
      'coverImageUrl': coverImageUrl,
    };
  }

  BookItem copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    String? size,
    int? totalPages,
    double? rating,
    String? description,
    String? pdfUrl,
    List<String>? samplePagesContent,
    String? accessType,
    double? price,
    double? originalPrice,
    bool? isPurchased,
    String? coverImageUrl,
  }) {
    return BookItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      size: size ?? this.size,
      totalPages: totalPages ?? this.totalPages,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      samplePagesContent: samplePagesContent ?? this.samplePagesContent,
      accessType: accessType ?? this.accessType,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isPurchased: isPurchased ?? this.isPurchased,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'bach flower therapy':
      case 'bach flower':
        return const Color(0xFF059669);
      case 'vastu shastra':
      case 'vastu':
        return const Color(0xFFD97706);
      case 'ayurveda':
        return const Color(0xFF4338CA);
      case 'graphology':
        return const Color(0xFF7C3AED);
      case 'drugless cure':
        return const Color(0xFF0288D1);
      default:
        return const Color(0xFF4338CA);
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        category,
        size,
        totalPages,
        rating,
        description,
        pdfUrl,
        samplePagesContent,
        accessType,
        price,
        originalPrice,
        isPurchased,
        coverImageUrl,
      ];
}
