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
    // Optimistic UI update
    if (state.hasValue) {
      final currentItems = state.value!.toList();
      final index = currentItems.indexWhere((i) => i.id == item.id);

      if (index >= 0) {
        currentItems[index] = currentItems[index].copyWith(
          quantity: currentItems[index].quantity + item.quantity,
        );
      } else {
        currentItems.add(item);
      }
      state = AsyncValue.data(currentItems);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      await _repository.addToCart(item);
      final updatedItems = await _fetchCartItems();
      state = AsyncValue.data(updatedItems);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates the quantity of a specific cart item.
  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      return removeItem(id);
    }

    // Optimistic UI update
    if (state.hasValue) {
      final currentItems = state.value!;
      final updatedItems = currentItems.map((item) {
        if (item.id == id) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList();

      state = AsyncValue.data(updatedItems);
    }

    try {
      await _repository.updateQuantity(id, quantity);
      final refreshedItems = await _fetchCartItems();
      state = AsyncValue.data(refreshedItems);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Removes an item entirely from the cart.
  Future<void> removeItem(String id) async {
    // Optimistic UI update
    if (state.hasValue) {
      final currentItems = state.value!;
      final updatedItems = currentItems.where((item) => item.id != id).toList();
      state = AsyncValue.data(updatedItems);
    }

    try {
      await _repository.removeFromCart(id);
      final refreshedItems = await _fetchCartItems();
      state = AsyncValue.data(refreshedItems);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clears all items in the cart.
  Future<void> clearCart() async {
    // Optimistic UI update
    state = const AsyncValue.data([]);

    try {
      await _repository.clearCart();
      final refreshedItems = await _fetchCartItems();
      state = AsyncValue.data(refreshedItems);
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

  int get totalItems => fold(0, (sum, item) => sum + item.quantity);
}
