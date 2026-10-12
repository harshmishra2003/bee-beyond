import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_ds.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    return await localDataSource.getCart();
  }

  @override
  Future<void> addToCart(CartItemEntity item) async {
    final current = await localDataSource.getCart();
    final index = current.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      current[index] = CartItemModel(
        id: item.id,
        title: item.title,
        imageUrl: item.imageUrl,
        price: item.price,
        quantity: current[index].quantity + 1,
      );
    } else {
      current.add(CartItemModel(
        id: item.id,
        title: item.title,
        imageUrl: item.imageUrl,
        price: item.price,
        quantity: item.quantity,
      ));
    }
    await localDataSource.saveCart(current);
  }

  @override
  Future<void> removeFromCart(String id) async {
    final current = await localDataSource.getCart();
    current.removeWhere((i) => i.id == id);
    await localDataSource.saveCart(current);
  }

  @override
  Future<void> updateQuantity(String id, int quantity) async {
    final current = await localDataSource.getCart();
    final index = current.indexWhere((i) => i.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
        current.removeAt(index);
      } else {
        current[index] = CartItemModel(
          id: id,
          title: current[index].title,
          imageUrl: current[index].imageUrl,
          price: current[index].price,
          quantity: quantity,
        );
      }
      await localDataSource.saveCart(current);
    }
  }

  @override
  Future<void> clearCart() async {
    await localDataSource.saveCart([]);
  }
}
