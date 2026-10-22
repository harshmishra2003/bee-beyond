import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/cart_local_ds.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(CartLocalDataSourceImpl());
});

final cartManagerProvider = AsyncNotifierProvider<CartManager, List<CartItemEntity>>(
  CartManager.new,
);

// -----------------------------------------------------------------------------
// Cart Manager (AsyncNotifier)
// -----------------------------------------------------------------------------

class CartManager extends AsyncNotifier<List<CartItemEntity>> {
  late final CartRepository _repository;

  @override
  Future<List<CartItemEntity>> build() async {
    _repository = ref.watch(cartRepositoryProvider);
    return _fetchCartItems();
  }

  Future<List<CartItemEntity>> _fetchCartItems() async {
    return await _repository.getCartItems();
  }

  /// Adds an item to the cart using optimistic UI updates for instant feedback.
  Future<void> addToCart(CartItemEntity item) async {
    final currentList = state.value ?? [];
    final updatedList = List<CartItemEntity>.from(currentList);
    final index = updatedList.indexWhere((i) => i.id == item.id);

    if (index >= 0) {
      updatedList[index] = updatedList[index].copyWith(
        quantity: updatedList[index].quantity + item.quantity,
      );
    } else {
      updatedList.add(item);
    }

    // Immediately set optimistic state
    state = AsyncValue.data(updatedList);

    try {
      await _repository.addToCart(item);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates the quantity of a specific cart item.
  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      return removeItem(id);
    }

    final currentItems = state.value ?? [];
    final updatedItems = currentItems.map((item) {
      if (item.id == id) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = AsyncValue.data(updatedItems);

    try {
      await _repository.updateQuantity(id, quantity);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Removes an item entirely from the cart.
  Future<void> removeItem(String id) async {
    final currentItems = state.value ?? [];
    final updatedItems = currentItems.where((item) => item.id != id).toList();

    state = AsyncValue.data(updatedItems);

    try {
      await _repository.removeFromCart(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clears all items in the cart.
  Future<void> clearCart() async {
    state = const AsyncValue.data([]);

    try {
      await _repository.clearCart();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// -----------------------------------------------------------------------------
// Extensions
// -----------------------------------------------------------------------------

extension CartStateExtension on List<CartItemEntity> {
  double get subtotal => fold(0, (sum, item) => sum + (item.price * item.quantity));

  // Calculates a 3% standard tax/fee as used in the UI
  double get taxAmount => subtotal * 0.03;

  double get totalPayable => subtotal + taxAmount;

  // Number of unique product items in cart (e.g. 1 product type = '1')
  int get totalUniqueItems => length;

  // Total quantity sum across all items
  int get totalQuantity => fold(0, (sum, item) => sum + item.quantity);

  // Cart Badge Indicator displays unique product items count
  int get totalItems => length;
}
