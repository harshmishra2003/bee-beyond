import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';

final purchasedBooksProvider = StateNotifierProvider<PurchasedBooksNotifier, Set<String>>((ref) {
  return PurchasedBooksNotifier();
});

class PurchasedBooksNotifier extends StateNotifier<Set<String>> {
  PurchasedBooksNotifier() : super(const {}) {
    _loadPurchasedBooks();
  }

  Future<void> _loadPurchasedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(StorageKeys.purchasedBooks);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(data);
        state = decoded.map((e) => e.toString()).toSet();
      }
    } catch (_) {
      state = {};
    }
  }

  Future<void> unlockBook(String bookId) async {
    final newState = Set<String>.from(state)..add(bookId);
    state = newState;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.purchasedBooks, jsonEncode(newState.toList()));
    } catch (_) {}
  }

  bool isBookUnlocked(String bookId) {
    return state.contains(bookId);
  }
}
