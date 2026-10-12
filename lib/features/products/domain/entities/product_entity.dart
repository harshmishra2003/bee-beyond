import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final double price;
  final double? originalPrice;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
  });

  @override
  List<Object?> get props => [id, title, description, category, imageUrl, price, originalPrice];
}
