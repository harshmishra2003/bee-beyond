import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _storageKey = 'bee_user_cart_items_v2';

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }
}
