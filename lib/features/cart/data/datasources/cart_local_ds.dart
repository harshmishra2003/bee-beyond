import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  List<CartItemModel> _memoryCart = [];

  @override
  Future<List<CartItemModel>> getCart() async {
    return List<CartItemModel>.from(_memoryCart);
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    _memoryCart = List<CartItemModel>.from(items);
  }
}
