import '../../../../core/constants/asset_paths.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  List<CartItemModel> _memoryCart = [
    const CartItemModel(
      id: 'p_1',
      title: 'Bach Flower Remedy Kit - 38 Essences Drop Set',
      imageUrl: AssetPaths.bachFlower,
      price: 2499.0,
      quantity: 1,
    ),
    const CartItemModel(
      id: 'jc_1',
      title: 'Breathwork For Emotional Release Certified Course',
      imageUrl: AssetPaths.ancientHealing,
      price: 8999.0,
      quantity: 1,
    ),
    const CartItemModel(
      id: 'p_2',
      title: 'Vastu Shastra Energy Crystal Pyramids Set',
      imageUrl: AssetPaths.vastu,
      price: 1299.0,
      quantity: 1,
    ),
  ];

  @override
  Future<List<CartItemModel>> getCart() async {
    return List<CartItemModel>.from(_memoryCart);
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    _memoryCart = List<CartItemModel>.from(items);
  }
}
