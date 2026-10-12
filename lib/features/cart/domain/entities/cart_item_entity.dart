import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;

  const CartItemEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      id: id,
      title: title,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, price, quantity];
}
