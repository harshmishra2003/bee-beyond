import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/asset_paths.dart';

class MembershipPlanContentItem extends Equatable {
  final String id;
  final String contentType; // 'course', 'video', 'pdf', 'music'
  final String relatedTable;
  final String contentId;
  final String accessType;
  final String title;

  const MembershipPlanContentItem({
    required this.id,
    required this.contentType,
    required this.relatedTable,
    required this.contentId,
    this.accessType = 'included',
    this.title = '',
  });

  factory MembershipPlanContentItem.fromJson(Map<String, dynamic> json) {
    return MembershipPlanContentItem(
      id: json['id']?.toString() ?? '',
      contentType: json['content_type']?.toString() ?? '',
      relatedTable: json['related_table']?.toString() ?? '',
      contentId: json['content_id']?.toString() ?? '',
      accessType: json['access_type']?.toString() ?? 'included',
      title: json['title']?.toString() ?? json['name']?.toString() ?? json['content_title']?.toString() ?? '',
    );
  }

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (contentType.toLowerCase() == 'course') return 'Adv. Bach Flower Course';
    if (contentType.toLowerCase() == 'video') return 'Bach Remedy Masterclass Video';
    if (contentType.toLowerCase() == 'pdf') return 'Ayurvedic Remedies E-Book PDF';
    if (contentType.toLowerCase() == 'music') return 'Healing Solfeggio Music Audio';
    return '${contentType.toUpperCase()} Access';
  }

  IconData get icon {
    final type = contentType.toLowerCase();
    if (type == 'course') return Icons.school_rounded;
    if (type == 'video') return Icons.play_circle_rounded;
    if (type == 'pdf' || type == 'book') return Icons.auto_stories_rounded;
    if (type == 'music' || type == 'audio') return Icons.music_note_rounded;
    return Icons.star_rounded;
  }

  Color get color {
    final type = contentType.toLowerCase();
    if (type == 'course') return const Color(0xFF0288D1);
    if (type == 'video') return const Color(0xFFD97706);
    if (type == 'pdf' || type == 'book') return const Color(0xFF059669);
    if (type == 'music' || type == 'audio') return const Color(0xFF6845C4);
    return const Color(0xFF059669);
  }

  @override
  List<Object?> get props => [id, contentType, relatedTable, contentId, accessType, title];
}

class MembershipPlanEntity extends Equatable {
  final String id;
  final String slug;
  final String name;
  final String tagline;
  final String badgeText;
  final String description;
  final double price;
  final double monthlyPrice;
  final double annualPrice;
  final String currency;
  final int accessDuration;
  final String accessType;
  final String durationLabel;
  final List<String> features;
  final List<MembershipPlanContentItem> contents;
  final List<Map<String, dynamic>> liveSessions;

  const MembershipPlanEntity({
    required this.id,
    required this.slug,
    required this.name,
    this.tagline = '',
    this.badgeText = '',
    this.description = '',
    required this.price,
    this.monthlyPrice = 199.0,
    this.annualPrice = 1999.0,
    this.currency = 'INR',
    this.accessDuration = 1,
    this.accessType = 'year',
    required this.durationLabel,
    this.features = const [],
    this.contents = const [],
    this.liveSessions = const [],
  });

  bool get isPopular =>
      badgeText.toLowerCase().contains('best') ||
      badgeText.toLowerCase().contains('popular') ||
      badgeText.toLowerCase().contains('recommended') ||
      badgeText.toLowerCase().contains('wow') ||
      slug.toLowerCase().contains('gold') ||
      slug.toLowerCase().contains('transform');

  String get bannerAssetPath {
    final lowerSlug = slug.toLowerCase();
    final lowerName = name.toLowerCase();

    if (lowerSlug.contains('bloom') || lowerName.contains('bloom') || lowerSlug == 'silver' || lowerSlug == '1') {
      return AssetPaths.bloomMembershipBanner;
    }
    if (lowerSlug.contains('elevate') || lowerName.contains('elevate') || lowerSlug == 'gold' || lowerSlug == '2') {
      return AssetPaths.elevateMembershipBanner;
    }
    if (lowerSlug.contains('transform') || lowerName.contains('transform') || lowerSlug == 'platinum' || lowerSlug == '3') {
      return AssetPaths.transformMembershipBanner;
    }
    if (lowerSlug.contains('infinity') || lowerName.contains('infinity') || lowerSlug == 'diamond' || lowerSlug == '4') {
      return AssetPaths.infinityMembershipBanner;
    }

    return AssetPaths.bloomMembershipBanner;
  }

  Color get cardThemeColor {
    final lowerSlug = slug.toLowerCase();
    final lowerName = name.toLowerCase();

    if (lowerSlug.contains('bloom') || lowerName.contains('bloom') || lowerSlug == 'silver' || lowerSlug == '1') {
      return const Color(0xFF7C3AED); // Bloom Vibrant Purple
    }
    if (lowerSlug.contains('elevate') || lowerName.contains('elevate') || lowerSlug == 'gold' || lowerSlug == '2') {
      return const Color(0xFF0D9488); // Elevate Emerald Teal
    }
    if (lowerSlug.contains('transform') || lowerName.contains('transform') || lowerSlug == 'platinum' || lowerSlug == '3') {
      return const Color(0xFFD97706); // Transform Rich Gold
    }
    if (lowerSlug.contains('infinity') || lowerName.contains('infinity') || lowerSlug == 'diamond' || lowerSlug == '4') {
      return const Color(0xFF5B21B6); // Infinity Deep Royal Purple
    }

    return const Color(0xFF7C3AED);
  }

  Color get cardLightBg {
    final lowerSlug = slug.toLowerCase();
    final lowerName = name.toLowerCase();

    if (lowerSlug.contains('bloom') || lowerName.contains('bloom') || lowerSlug == 'silver' || lowerSlug == '1') {
      return const Color(0xFFF5F3FF); // Light Purple Tint
    }
    if (lowerSlug.contains('elevate') || lowerName.contains('elevate') || lowerSlug == 'gold' || lowerSlug == '2') {
      return const Color(0xFFF0FDFA); // Light Teal Tint
    }
    if (lowerSlug.contains('transform') || lowerName.contains('transform') || lowerSlug == 'platinum' || lowerSlug == '3') {
      return const Color(0xFFFFFBEB); // Light Amber Tint
    }
    if (lowerSlug.contains('infinity') || lowerName.contains('infinity') || lowerSlug == 'diamond' || lowerSlug == '4') {
      return const Color(0xFFF3E8FF); // Light Royal Violet Tint
    }

    return const Color(0xFFF5F3FF);
  }

  List<Color> get gradientColors {
    final themeColor = cardThemeColor;
    return [
      themeColor,
      themeColor.withValues(alpha: 0.85),
    ];
  }

  IconData get icon {
    final lowerSlug = slug.toLowerCase();
    final lowerName = name.toLowerCase();
    if (lowerSlug.contains('bloom') || lowerName.contains('bloom')) {
      return Icons.local_florist_rounded;
    }
    if (lowerSlug.contains('elevate') || lowerName.contains('elevate')) {
      return Icons.trending_up_rounded;
    }
    if (lowerSlug.contains('transform') || lowerName.contains('transform')) {
      return Icons.auto_awesome_rounded;
    }
    if (lowerSlug.contains('infinity') || lowerName.contains('infinity')) {
      return Icons.all_inclusive_rounded;
    }
    return Icons.workspace_premium_rounded;
  }

  String get displayName {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('membership') || lowerName.contains('card') || lowerName.contains('pass')) {
      return name.toUpperCase();
    }
    return '${name.substring(0, 1).toUpperCase()}${name.substring(1)} Membership Card';
  }

  String get displayTagline {
    if (tagline.isNotEmpty) return tagline.toUpperCase();
    return '${slug.toUpperCase()} PASS';
  }

  String get displayBadgeText {
    if (badgeText.isNotEmpty) return badgeText.toUpperCase();
    if (isPopular) return 'BEST VALUE';
    return 'VIP PASS';
  }

  @override
  List<Object?> get props => [
        id,
        slug,
        name,
        tagline,
        badgeText,
        description,
        price,
        monthlyPrice,
        annualPrice,
        currency,
        accessDuration,
        accessType,
        durationLabel,
        features,
        contents,
        liveSessions,
      ];
}
