import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _storageKey = 'bee_user_cart_items_v2';
  List<CartItemModel>? _cachedCart;

  @override
  Future<List<CartItemModel>> getCart() async {
    if (_cachedCart != null) {
      return List<CartItemModel>.from(_cachedCart!);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final list = decoded
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _cachedCart = list;
        return List<CartItemModel>.from(list);
      }
    } catch (_) {}

    _cachedCart = [];
    return [];
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    _cachedCart = List<CartItemModel>.from(items);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }
}
