import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final int maxAllowedQuantity;

  const CartItemEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.maxAllowedQuantity = 5,
  });

  CartItemEntity copyWith({int? quantity, int? maxAllowedQuantity}) {
    return CartItemEntity(
      id: id,
      title: title,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity ?? this.quantity,
      maxAllowedQuantity: maxAllowedQuantity ?? this.maxAllowedQuantity,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, imageUrl, price, quantity, maxAllowedQuantity];
}
