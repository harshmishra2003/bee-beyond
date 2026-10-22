import 'package:equatable/equatable.dart';

class ProductUnitOption extends Equatable {
  final String label;
  final double price;
  final double? mrp;

  const ProductUnitOption({
    required this.label,
    required this.price,
    this.mrp,
  });

  factory ProductUnitOption.fromJson(dynamic json, double defaultBasePrice, double? defaultMrp) {
    if (json is Map<String, dynamic>) {
      final lbl = json['label']?.toString() ??
          json['unit']?.toString() ??
          json['size']?.toString() ??
          json['weight']?.toString() ??
          '1 Unit';

      final p = (json['price'] as num?)?.toDouble() ??
          (json['sale_price'] as num?)?.toDouble() ??
          double.tryParse(json['price']?.toString() ?? '') ??
          defaultBasePrice;

      final m = (json['mrp'] as num?)?.toDouble() ??
          (json['original_price'] as num?)?.toDouble() ??
          defaultMrp;

      return ProductUnitOption(
        label: lbl,
        price: p > 0 ? p : defaultBasePrice,
        mrp: m,
      );
    } else if (json is String) {
      final str = json.trim();
      double p = defaultBasePrice;
      if (str.contains('1 kg') || str.contains('1 L') || str.contains('Pack of 2') || str.contains('2N')) {
        p = defaultBasePrice * 1.8;
      } else if (str.contains('100 g') || str.contains('100 ml')) {
        p = defaultBasePrice * 0.4;
      } else if (str.contains('250 g') || str.contains('200 ml')) {
        p = defaultBasePrice * 0.65;
      } else if (str.contains('5 L') || str.contains('3N') || str.contains('Pack of 3')) {
        p = defaultBasePrice * 2.6;
      }
      return ProductUnitOption(label: str, price: p, mrp: defaultMrp != null ? defaultMrp * (p / defaultBasePrice) : null);
    }
    return ProductUnitOption(label: '500 g', price: defaultBasePrice, mrp: defaultMrp);
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'price': price,
      'mrp': mrp,
    };
  }

  @override
  List<Object?> get props => [label, price, mrp];
}

class ProductEntity extends Equatable {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String category;
  final String? subCategory;
  final String imageUrl;
  final List<String> galleryImages;
  final double price; // Base sale price
  final double? originalPrice; // Base MRP
  final bool inStock;
  final int availableQuantity;
  final int minOrderQuantity;
  final int maxOrderLimit;
  final String unitType;
  final List<ProductUnitOption> unitOptions;

  const ProductEntity({
    required this.id,
    this.categoryId = '',
    required this.title,
    required this.description,
    required this.category,
    this.subCategory,
    required this.imageUrl,
    this.galleryImages = const [],
    required this.price,
    this.originalPrice,
    this.inStock = true,
    this.availableQuantity = 1,
    this.minOrderQuantity = 1,
    this.maxOrderLimit = 5,
    this.unitType = '500 g',
    this.unitOptions = const [
      ProductUnitOption(label: '250 g', price: 280),
      ProductUnitOption(label: '500 g', price: 550),
      ProductUnitOption(label: '1 kg', price: 980),
      ProductUnitOption(label: '2N Pack', price: 1050),
    ],
  });

  /// Maximum allowed quantity a user can purchase in a single order
  int get effectiveMaxQuantity {
    if (availableQuantity <= 0) return 0;
    if (maxOrderLimit > 0) {
      return maxOrderLimit < availableQuantity ? maxOrderLimit : availableQuantity;
    }
    return availableQuantity < 5 ? availableQuantity : 5;
  }

  List<String> get allImages {
    final List<String> list = [];
    if (imageUrl.isNotEmpty) list.add(imageUrl);
    for (final img in galleryImages) {
      if (img.isNotEmpty && !list.contains(img)) {
        list.add(img);
      }
    }
    return list.isNotEmpty ? list : (imageUrl.isNotEmpty ? [imageUrl] : []);
  }

  int calculateDiscountPercent(double activePrice) {
    if (originalPrice != null && originalPrice! > activePrice && originalPrice! > 0) {
      return (((originalPrice! - activePrice) / originalPrice!) * 100).round();
    }
    return 0;
  }

  int get discountPercent => calculateDiscountPercent(price);

  @override
  List<Object?> get props => [
        id,
        categoryId,
        title,
        description,
        category,
        subCategory,
        imageUrl,
        galleryImages,
        price,
        originalPrice,
        inStock,
        availableQuantity,
        minOrderQuantity,
        maxOrderLimit,
        unitType,
        unitOptions,
      ];
}
