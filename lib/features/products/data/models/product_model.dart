import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.imageUrl,
    required super.price,
    super.originalPrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? json['product_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Healing Store',
      imageUrl: json['imageUrl']?.toString() ??
          json['image_url']?.toString() ??
          json['image']?.toString() ??
          '',
      price: (json['price'] as num?)?.toDouble() ??
          double.tryParse(json['price']?.toString() ?? '0') ??
          0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ??
          (json['original_price'] as num?)?.toDouble() ??
          double.tryParse(json['original_price']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'price': price,
      'originalPrice': originalPrice,
    };
  }
}
