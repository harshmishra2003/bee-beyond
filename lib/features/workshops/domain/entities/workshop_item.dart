import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WorkshopItem extends Equatable {
  final String id;
  final String title;
  final String instructor;
  final String lineage;
  final String category;
  final String description;
  final String duration;
  final double basePrice;
  final double discount;
  final double rating;
  final String thumbnailUrl;
  final String videoUrl;
  final List<String> takeaways;
  final List<String> upcomingDates;
  final bool isLive;
  final int views;

  const WorkshopItem({
    required this.id,
    required this.title,
    required this.instructor,
    required this.lineage,
    required this.category,
    required this.description,
    required this.duration,
    required this.basePrice,
    required this.discount,
    required this.rating,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.takeaways,
    required this.upcomingDates,
    required this.isLive,
    required this.views,
  });

  double get finalPrice {
    final net = basePrice - discount;
    return net > 0 ? net : 0.0;
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'sound healing':
      case 'audio':
        return const Color(0xFF8B5CF6);
      case 'ayurveda':
      case 'wellness':
        return const Color(0xFF10B981);
      case 'vastu':
      case 'energy':
        return const Color(0xFFD97706);
      case 'meditation':
      case 'mind':
        return const Color(0xFF0288D1);
      case 'life coaching':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String get categoryBadge {
    if (isLive) return '🔴 LIVE MASTERCLASS';
    return '📹 VIDEO WORKSHOP';
  }

  static String fixImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    const baseUrl = 'https://metricstestingapp.xyz';
    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }
    return '$baseUrl/$trimmed';
  }

  factory WorkshopItem.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
      if (val is String && val.trim().isNotEmpty) {
        return val.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    final rawBasePrice = double.tryParse(
      json['base_price']?.toString() ?? json['basePrice']?.toString() ?? json['price']?.toString() ?? '0',
    ) ?? 0.0;

    final rawSalePrice = double.tryParse(
      json['sale_price']?.toString() ?? json['salePrice']?.toString() ?? '0',
    ) ?? 0.0;

    final rawDiscount = double.tryParse(
      json['discount']?.toString() ?? '0',
    ) ?? 0.0;

    double calculatedDiscount = rawDiscount;
    if (rawBasePrice > 0 && rawSalePrice > 0 && rawBasePrice >= rawSalePrice) {
      calculatedDiscount = rawBasePrice - rawSalePrice;
    }

    final rawRating = double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0;
    final displayRating = rawRating > 0 ? rawRating : 4.8;

    final deliveryType = json['delivery_type']?.toString().toLowerCase() ?? '';
    final isLiveVal = deliveryType == 'live' ||
        json['isLive'] == true ||
        json['is_live'] == 1 ||
        json['is_live'] == '1' ||
        json['type'] == 'live';

    final rawImg = json['thumbnail_url']?.toString() ??
        json['thumbnailUrl']?.toString() ??
        json['image']?.toString() ??
        '';

    final startDt = json['start_datetime']?.toString() ?? '';
    final endDt = json['end_datetime']?.toString() ?? '';
    List<String> datesList = parseList(json['upcomingDates'] ?? json['dates']);
    if (datesList.isEmpty && startDt.isNotEmpty) {
      if (endDt.isNotEmpty) {
        datesList = ['Start: $startDt', 'End: $endDt'];
      } else {
        datesList = ['Start Date: $startDt'];
      }
    }

    final categoryStr = json['category']?.toString() ?? 'Wellness & Remedies';
    final subcategoryStr = json['subcategory']?.toString() ?? '';
    final mentorName = json['mentor_name']?.toString() ??
        json['instructor']?.toString() ??
        json['mentor']?.toString() ??
        'Certified Instructor';

    final lineageStr = subcategoryStr.isNotEmpty && subcategoryStr != categoryStr
        ? subcategoryStr
        : 'Accredited Wellness Masterclass';

    return WorkshopItem(
      id: json['id']?.toString() ?? json['workshop_id']?.toString() ?? 'ws_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Holistic Masterclass',
      instructor: mentorName,
      lineage: lineageStr,
      category: categoryStr,
      description: json['description']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '2 Hours',
      basePrice: rawBasePrice > 0 ? rawBasePrice : (rawSalePrice > 0 ? rawSalePrice : 1000.0),
      discount: calculatedDiscount,
      rating: displayRating,
      thumbnailUrl: fixImageUrl(rawImg),
      videoUrl: json['videoUrl']?.toString() ?? json['video_url']?.toString() ?? '',
      takeaways: parseList(json['takeaways'] ?? json['highlights']),
      upcomingDates: datesList,
      isLive: isLiveVal,
      views: int.tryParse(json['available_seats']?.toString() ?? json['capacity']?.toString() ?? json['views']?.toString() ?? '100') ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'lineage': lineage,
      'category': category,
      'description': description,
      'duration': duration,
      'basePrice': basePrice,
      'discount': discount,
      'rating': rating,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'takeaways': takeaways,
      'upcomingDates': upcomingDates,
      'isLive': isLive,
      'views': views,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        instructor,
        lineage,
        category,
        description,
        duration,
        basePrice,
        discount,
        rating,
        thumbnailUrl,
        videoUrl,
        takeaways,
        upcomingDates,
        isLive,
        views,
      ];
}
