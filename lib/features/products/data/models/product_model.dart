import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    super.categoryId = '',
    required super.title,
    required super.description,
    required super.category,
    super.subCategory,
    required super.imageUrl,
    super.galleryImages = const [],
    required super.price,
    super.originalPrice,
    super.inStock = true,
    super.availableQuantity = 1,
    super.minOrderQuantity = 1,
    super.maxOrderLimit = 5,
    super.unitType = '500 g',
    super.unitOptions = const [],
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawSalePrice = json['sale_price'] ??
        json['price'] ??
        json['salePrice'] ??
        json['discount_price'] ??
        0.0;

    double salePrice = 0.0;
    if (rawSalePrice is num) {
      salePrice = rawSalePrice.toDouble();
    } else if (rawSalePrice != null) {
      salePrice = double.tryParse(rawSalePrice.toString()) ?? 0.0;
    }

    final rawMrp = json['mrp'] ??
        json['originalPrice'] ??
        json['original_price'] ??
        json['regular_price'] ??
        0.0;

    double mrpPrice = 0.0;
    if (rawMrp is num) {
      mrpPrice = rawMrp.toDouble();
    } else if (rawMrp != null) {
      mrpPrice = double.tryParse(rawMrp.toString()) ?? 0.0;
    }

    final rawImgUrl = json['image_url']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image']?.toString() ??
        json['product_image']?.toString() ??
        '';

    final imgUrl = _formatUrl(rawImgUrl);

    List<String> parsedGallery = [];
    final rawGallery = json['images'] ?? json['image_urls'] ?? json['gallery'] ?? json['photos'];
    if (rawGallery is List && rawGallery.isNotEmpty) {
      parsedGallery = rawGallery
          .map((e) => _formatUrl(e?.toString()))
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final title = json['name']?.toString() ??
        json['title']?.toString() ??
        json['product_name']?.toString() ??
        'Healing Product';

    final category = json['category']?.toString() ??
        json['category_name']?.toString() ??
        'Healing Store';

    final subCategory = json['subCategory']?.toString() ??
        json['sub_category']?.toString() ??
        json['subcategory']?.toString();

    final bool inStockFlag = json['in_stock'] == true ||
        json['in_stock']?.toString() == '1' ||
        json['status'] == 1 ||
        json['status']?.toString() == '1';

    final rawQty = json['available_quantity'] ?? json['quantity'] ?? json['qty'] ?? 1;
    int qty = 1;
    if (rawQty is num) {
      qty = rawQty.toInt();
    } else if (rawQty != null) {
      qty = int.tryParse(rawQty.toString()) ?? 1;
    }

    final rawMinQty = json['minimum_order_quantity'] ?? json['min_qty'] ?? 1;
    int minQty = 1;
    if (rawMinQty is num) {
      minQty = rawMinQty.toInt();
    } else if (rawMinQty != null) {
      minQty = int.tryParse(rawMinQty.toString()) ?? 1;
    }

    final rawMaxLimit = json['max_order_limit'] ??
        json['maximum_order_quantity'] ??
        json['max_limit'] ??
        json['max_qty'] ??
        5;

    int maxLimit = 5;
    if (rawMaxLimit is num) {
      maxLimit = rawMaxLimit.toInt();
    } else if (rawMaxLimit != null) {
      maxLimit = int.tryParse(rawMaxLimit.toString()) ?? 5;
    }

    final unitStr = json['unit']?.toString() ??
        json['unit_type']?.toString() ??
        json['weight']?.toString() ??
        json['size']?.toString() ??
        '500 g';

    List<ProductUnitOption> parsedUnitOptions = [];
    final rawOptions = json['unit_options'] ?? json['units'] ?? json['sizes'] ?? json['variants'];

    final basePrice = salePrice > 0 ? salePrice : mrpPrice;

    if (rawOptions is List && rawOptions.isNotEmpty) {
      parsedUnitOptions = rawOptions
          .map((opt) => ProductUnitOption.fromJson(opt, basePrice, mrpPrice > basePrice ? mrpPrice : null))
          .toList();
    } else {
      final catLower = category.toLowerCase();
      if (catLower.contains('oil') || catLower.contains('liquid') || catLower.contains('drop')) {
        parsedUnitOptions = [
          ProductUnitOption(label: '100 ml', price: (basePrice * 0.45).roundToDouble()),
          ProductUnitOption(label: '200 ml', price: (basePrice * 0.70).roundToDouble()),
          ProductUnitOption(label: '500 ml', price: basePrice),
          ProductUnitOption(label: '1 L', price: (basePrice * 1.85).roundToDouble()),
        ];
      } else if (catLower.contains('tea') || catLower.contains('powder') || catLower.contains('upchar')) {
        parsedUnitOptions = [
          ProductUnitOption(label: '100 g', price: (basePrice * 0.40).roundToDouble()),
          ProductUnitOption(label: '250 g', price: (basePrice * 0.65).roundToDouble()),
          ProductUnitOption(label: '500 g', price: basePrice),
          ProductUnitOption(label: '1 kg', price: (basePrice * 1.80).roundToDouble()),
        ];
      } else {
        parsedUnitOptions = [
          ProductUnitOption(label: '1N', price: basePrice),
          ProductUnitOption(label: '2N (Pack of 2)', price: (basePrice * 1.80).roundToDouble()),
          ProductUnitOption(label: '3N (Pack of 3)', price: (basePrice * 2.50).roundToDouble()),
        ];
      }
    }

    return ProductModel(
      id: json['id']?.toString() ?? json['product_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      title: title,
      description: json['description']?.toString() ?? '',
      category: category,
      subCategory: subCategory,
      imageUrl: imgUrl,
      galleryImages: parsedGallery,
      price: basePrice,
      originalPrice: mrpPrice > basePrice ? mrpPrice : null,
      inStock: inStockFlag,
      availableQuantity: qty > 0 ? qty : 1,
      minOrderQuantity: minQty > 0 ? minQty : 1,
      maxOrderLimit: maxLimit > 0 ? maxLimit : 5,
      unitType: unitStr,
      unitOptions: parsedUnitOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': title,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'image_url': imageUrl,
      'images': galleryImages,
      'sale_price': price,
      'mrp': originalPrice ?? price,
      'in_stock': inStock,
      'available_quantity': availableQuantity,
      'minimum_order_quantity': minOrderQuantity,
      'max_order_limit': maxOrderLimit,
      'unit_options': unitOptions.map((u) => u.toJson()).toList(),
    };
  }
}
