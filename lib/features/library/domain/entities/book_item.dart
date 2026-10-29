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
  });

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

    final rawAuthor = json['author']?.toString() ?? json['author_name']?.toString() ?? '';
    final authorStr = rawAuthor.trim().isNotEmpty ? rawAuthor.trim() : 'Bee Beyonnd Vault';

    final rawCategory = json['category']?.toString() ??
        json['subCategory']?.toString() ??
        json['category_name']?.toString() ??
        'General';

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
    };
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
  List<Object?> get props => [id, title, author, category, size, totalPages, rating, description, pdfUrl, samplePagesContent];
}
