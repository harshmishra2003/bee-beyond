import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> addToCart(CartItemEntity item);
  Future<void> removeFromCart(String id);
  Future<void> updateQuantity(String id, int quantity);
  Future<void> clearCart();
}
