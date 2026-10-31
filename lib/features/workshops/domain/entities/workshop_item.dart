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

    return WorkshopItem(
      id: json['id']?.toString() ?? json['workshop_id']?.toString() ?? 'ws_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Certified Holistic Workshop',
      instructor: json['instructor']?.toString() ?? json['mentor']?.toString() ?? 'Acharya Devraj',
      lineage: json['lineage']?.toString() ?? '35 Yrs Sacred Vedic Lineage',
      category: json['category']?.toString() ?? 'Ayurveda & Wellness',
      description: json['description']?.toString() ?? 'Interactive masterclass offering hands-on training and certification.',
      duration: json['duration']?.toString() ?? '2.5 Hours',
      basePrice: double.tryParse(json['basePrice']?.toString() ?? json['price']?.toString() ?? '1499') ?? 1499.0,
      discount: double.tryParse(json['discount']?.toString() ?? '300') ?? 300.0,
      rating: double.tryParse(json['rating']?.toString() ?? '4.9') ?? 4.9,
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? json['image']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? json['video_url']?.toString() ?? '',
      takeaways: parseList(json['takeaways'] ?? json['highlights']),
      upcomingDates: parseList(json['upcomingDates'] ?? json['dates']),
      isLive: json['isLive'] == true || json['is_live'] == 1 || json['type'] == 'live',
      views: int.tryParse(json['views']?.toString() ?? '1250') ?? 1250,
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
