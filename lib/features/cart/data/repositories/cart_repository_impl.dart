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
    final maxCap = item.maxAllowedQuantity > 0 ? item.maxAllowedQuantity : 5;

    if (index >= 0) {
      final totalQty = current[index].quantity + item.quantity;
      current[index] = CartItemModel(
        id: item.id,
        title: item.title,
        imageUrl: item.imageUrl,
        price: item.price,
        quantity: totalQty <= maxCap ? totalQty : maxCap,
        maxAllowedQuantity: maxCap,
      );
    } else {
      final initQty = item.quantity > 0 ? item.quantity : 1;
      current.add(CartItemModel(
        id: item.id,
        title: item.title,
        imageUrl: item.imageUrl,
        price: item.price,
        quantity: initQty <= maxCap ? initQty : maxCap,
        maxAllowedQuantity: maxCap,
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
        final maxCap = current[index].maxAllowedQuantity > 0
            ? current[index].maxAllowedQuantity
            : 5;
        current[index] = CartItemModel(
          id: id,
          title: current[index].title,
          imageUrl: current[index].imageUrl,
          price: current[index].price,
          quantity: quantity <= maxCap ? quantity : maxCap,
          maxAllowedQuantity: maxCap,
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
