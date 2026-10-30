import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';

class ServiceSlot extends Equatable {
  final String slotId;
  final String timeLabel;
  final bool isBooked;
  final bool isBookedByMe;

  const ServiceSlot({
    required this.slotId,
    required this.timeLabel,
    this.isBooked = false,
    this.isBookedByMe = false,
  });

  factory ServiceSlot.fromJson(Map<String, dynamic> json) {
    return ServiceSlot(
      slotId: json['slot_id']?.toString() ?? '',
      timeLabel: json['time_label']?.toString() ?? '',
      isBooked: json['is_booked'] == true || json['is_booked'] == 'true' || json['is_booked'] == 1,
      isBookedByMe: json['is_booked_by_me'] == true || json['is_booked_by_me'] == 'true' || json['is_booked_by_me'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slot_id': slotId,
      'time_label': timeLabel,
      'is_booked': isBooked,
      'is_booked_by_me': isBookedByMe,
    };
  }

  @override
  List<Object?> get props => [slotId, timeLabel, isBooked, isBookedByMe];
}

class ServiceMedia extends Equatable {
  final String title;
  final String url;

  const ServiceMedia({required this.title, required this.url});

  factory ServiceMedia.fromJson(Map<String, dynamic> json) {
    return ServiceMedia(
      title: json['title']?.toString() ?? 'Document',
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'url': url};

  @override
  List<Object?> get props => [title, url];
}

class ServiceItem extends Equatable {
  final String id;
  final String categoryId;
  final String category;
  final String serviceName;
  final String offerImageUrl;
  final String descriptionImageUrl;
  final double serviceCharge;
  final double offerPrice; // Original MRP
  final int status;
  final String duration;
  final IconData icon;

  // New Fields for Real-Time Slot Booking
  final String meetingLink;
  final List<ServiceMedia> mediaPdfs;
  final List<ServiceMedia> mediaVideos;
  final int totalSlotsToday;
  final int bookedSlotsCount;
  final int remainingSlotsCount;
  final List<ServiceSlot> slots;

  const ServiceItem({
    required this.id,
    this.categoryId = '',
    required this.category,
    required this.serviceName,
    required this.offerImageUrl,
    this.descriptionImageUrl = '',
    required this.serviceCharge,
    required this.offerPrice,
    this.status = 1,
    this.duration = '45 Mins Session',
    required this.icon,
    this.meetingLink = '',
    this.mediaPdfs = const [],
    this.mediaVideos = const [],
    this.totalSlotsToday = 0,
    this.bookedSlotsCount = 0,
    this.remainingSlotsCount = 0,
    this.slots = const [],
  });

  static String _formatUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    String trimmed = url.trim();

    if (trimmed.contains('localhost')) {
      trimmed = trimmed.replaceAll('http://localhost', 'https://metricstestingapp.xyz');
      trimmed = trimmed.replaceAll('https://localhost', 'https://metricstestingapp.xyz');
    }
    if (trimmed.contains('127.0.0.1')) {
      trimmed = trimmed.replaceAll('http://127.0.0.1', 'https://metricstestingapp.xyz');
      trimmed = trimmed.replaceAll('https://127.0.0.1', 'https://metricstestingapp.xyz');
    }

    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('assets/')) {
      return trimmed;
    }

    String baseUrl = ApiEndpoints.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }
    return '$baseUrl/$trimmed';
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    final rawCharge = json['service_charge'] ?? json['charge'] ?? json['price'];
    double charge = 0.0;
    if (rawCharge is num) {
      charge = rawCharge.toDouble();
    } else if (rawCharge != null) {
      charge = double.tryParse(rawCharge.toString()) ?? 0.0;
    }

    final rawOfferPrice = json['offer_price'] ?? json['original_price'] ?? json['mrp'];
    double origPrice = 0.0;
    if (rawOfferPrice is num) {
      origPrice = rawOfferPrice.toDouble();
    } else if (rawOfferPrice != null) {
      origPrice = double.tryParse(rawOfferPrice.toString()) ?? 0.0;
    }

    final offerImg = _formatUrl(json['offer_image_url']?.toString() ??
        json['offer_image']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString());

    final descImg = _formatUrl(json['description_image_url']?.toString() ??
        json['description_image']?.toString() ??
        json['desc_image']?.toString());

    final name = json['service_name']?.toString() ??
        json['title']?.toString() ??
        json['name']?.toString() ??
        'Wellness Consultation';

    final category = json['category']?.toString() ??
        json['category_name']?.toString() ??
        'Ayurvedic Upchar';

    List<ServiceSlot> parsedSlots = [];
    if (json['slots'] != null && json['slots'] is List) {
      parsedSlots = (json['slots'] as List).map((e) => ServiceSlot.fromJson(e)).toList();
    }

    List<ServiceMedia> parsedPdfs = [];
    if (json['media_pdfs'] != null && json['media_pdfs'] is List) {
      parsedPdfs = (json['media_pdfs'] as List).map((e) => ServiceMedia.fromJson(e)).toList();
    }

    List<ServiceMedia> parsedVideos = [];
    if (json['media_videos'] != null && json['media_videos'] is List) {
      parsedVideos = (json['media_videos'] as List).map((e) => ServiceMedia.fromJson(e)).toList();
    }

    final int total = (json['total_slots_today'] as num?)?.toInt() ?? parsedSlots.length;
    final int booked = (json['booked_slots_count'] as num?)?.toInt() ?? parsedSlots.where((s) => s.isBooked).length;
    final int remaining = (json['remaining_slots_count'] as num?)?.toInt() ?? (total - booked);

    return ServiceItem(
      id: json['id']?.toString() ?? json['service_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      category: category,
      serviceName: name,
      offerImageUrl: offerImg,
      descriptionImageUrl: descImg,
      serviceCharge: charge,
      offerPrice: origPrice > 0 ? origPrice : (charge > 0 ? charge * 1.5 : 0.0),
      status: (json['status'] as num?)?.toInt() ?? 1,
      duration: json['duration']?.toString() ?? '45 Mins Private Session',
      icon: _parseIcon(category),
      meetingLink: json['meeting_link']?.toString() ?? '',
      mediaPdfs: parsedPdfs,
      mediaVideos: parsedVideos,
      totalSlotsToday: total,
      bookedSlotsCount: booked,
      remainingSlotsCount: remaining < 0 ? 0 : remaining,
      slots: parsedSlots,
    );
  }

  static IconData _parseIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'home_work':
      case 'vastu':
      case 'vastu shastra':
        return Icons.home_work_outlined;
      case 'florist':
      case 'flower':
      case 'bach flower':
        return Icons.local_florist_outlined;
      case 'fingerprint':
      case 'dmit':
        return Icons.fingerprint_outlined;
      case 'edit_note':
      case 'graphology':
        return Icons.edit_note_outlined;
      case 'spa':
      case 'ayurveda':
      case 'ayurvedic upchar':
        return Icons.spa_outlined;
      default:
        return Icons.psychology_outlined;
    }
  }

  // Backwards compatibility getters
  String get title => serviceName;
  String get description => '1-on-1 Certified $category Consultation & Treatment Plan';
  String get price => '₹ ${serviceCharge.toInt()}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category': category,
      'service_name': serviceName,
      'offer_image_url': offerImageUrl,
      'description_image_url': descriptionImageUrl,
      'service_charge': serviceCharge,
      'offer_price': offerPrice,
      'status': status,
      'duration': duration,
      'meeting_link': meetingLink,
      'media_pdfs': mediaPdfs.map((e) => e.toJson()).toList(),
      'media_videos': mediaVideos.map((e) => e.toJson()).toList(),
      'total_slots_today': totalSlotsToday,
      'booked_slots_count': bookedSlotsCount,
      'remaining_slots_count': remainingSlotsCount,
      'slots': slots.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        category,
        serviceName,
        offerImageUrl,
        descriptionImageUrl,
        serviceCharge,
        offerPrice,
        status,
        duration,
        icon,
        meetingLink,
        mediaPdfs,
        mediaVideos,
        totalSlotsToday,
        bookedSlotsCount,
        remainingSlotsCount,
        slots,
      ];
}
