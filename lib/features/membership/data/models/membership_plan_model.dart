import '../../domain/entities/membership_plan_entity.dart';

class MembershipPlanModel extends MembershipPlanEntity {
  const MembershipPlanModel({
    required super.id,
    required super.slug,
    required super.name,
    super.tagline,
    super.badgeText,
    super.description,
    required super.price,
    super.monthlyPrice,
    super.annualPrice,
    super.currency,
    super.accessDuration,
    super.accessType,
    required super.durationLabel,
    super.features,
    super.contents,
    super.liveSessions,
  });

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    String cleanFeatureText(String text) {
      return text
          .replaceAll('■', '₹')
          .replaceAll('\u25a0', '₹')
          .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
          .trim();
    }

    final rawFeatures = json['features'];
    List<String> parsedFeatures = [];
    if (rawFeatures is List) {
      for (var e in rawFeatures) {
        if (e is Map && e.containsKey('feature_text')) {
          parsedFeatures.add(cleanFeatureText(e['feature_text'].toString()));
        } else if (e != null) {
          parsedFeatures.add(cleanFeatureText(e.toString()));
        }
      }
    } else if (rawFeatures is String && rawFeatures.isNotEmpty) {
      parsedFeatures = rawFeatures
          .split(',')
          .map((e) => cleanFeatureText(e.trim()))
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Parse prices array or direct properties
    double parsedMonthly = 199.0;
    double parsedAnnual = 1999.0;

    if (json['prices'] is List) {
      for (var p in json['prices']) {
        if (p is Map) {
          final period = p['billing_period']?.toString().toLowerCase();
          final val = double.tryParse(p['price']?.toString() ?? '') ?? 0.0;
          if (period == 'month' || period == 'monthly') {
            parsedMonthly = val;
          } else if (period == 'year' || period == 'annual' || period == 'yearly') {
            parsedAnnual = val;
          }
        }
      }
    }

    if (json['monthly_price'] != null) {
      parsedMonthly = double.tryParse(json['monthly_price'].toString()) ?? parsedMonthly;
    }

    if (json['annual_price'] != null) {
      parsedAnnual = double.tryParse(json['annual_price'].toString()) ?? parsedAnnual;
    }

    final rawPrice = json['price'] ?? parsedAnnual;
    double parsedPrice = 0.0;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice != null) {
      parsedPrice = double.tryParse(rawPrice.toString()) ?? 0.0;
    }
    if (parsedPrice == 0.0) parsedPrice = parsedAnnual;

    // Parse contents list
    List<MembershipPlanContentItem> parsedContents = [];
    if (json['contents'] is List) {
      for (var c in json['contents']) {
        if (c is Map<String, dynamic>) {
          parsedContents.add(MembershipPlanContentItem.fromJson(c));
        }
      }
    }

    // Parse live sessions
    List<Map<String, dynamic>> parsedLiveSessions = [];
    if (json['live_sessions'] is List) {
      for (var ls in json['live_sessions']) {
        if (ls is Map<String, dynamic>) {
          parsedLiveSessions.add(ls);
        }
      }
    }

    return MembershipPlanModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? json['name']?.toString() ?? 'plan',
      name: json['name']?.toString() ?? 'Membership Pass',
      tagline: json['tagline']?.toString() ?? '',
      badgeText: json['badge_text']?.toString() ?? json['badge']?.toString() ?? '',
      description: json['description']?.toString() ?? json['details']?.toString() ?? '',
      price: parsedPrice,
      monthlyPrice: parsedMonthly,
      annualPrice: parsedAnnual,
      currency: json['currency']?.toString() ?? 'INR',
      accessDuration: (json['access_duration'] as num?)?.toInt() ?? 1,
      accessType: json['access_type']?.toString() ?? 'year',
      durationLabel: json['duration_label']?.toString() ?? '1 YEAR ACCESS',
      features: parsedFeatures,
      contents: parsedContents,
      liveSessions: parsedLiveSessions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'tagline': tagline,
      'badge_text': badgeText,
      'description': description,
      'price': price,
      'monthly_price': monthlyPrice,
      'annual_price': annualPrice,
      'currency': currency,
      'access_duration': accessDuration,
      'access_type': accessType,
      'duration_label': durationLabel,
      'features': features,
      'contents': contents.map((c) => {
        'id': c.id,
        'content_type': c.contentType,
        'related_table': c.relatedTable,
        'content_id': c.contentId,
        'access_type': c.accessType,
        'title': c.title,
      }).toList(),
      'live_sessions': liveSessions,
    };
  }
}
