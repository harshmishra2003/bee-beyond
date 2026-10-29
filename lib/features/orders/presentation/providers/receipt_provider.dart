import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/receipt_entity.dart';

final receiptsProvider = StateNotifierProvider<ReceiptsNotifier, List<ReceiptEntity>>((ref) {
  return ReceiptsNotifier();
});

class ReceiptsNotifier extends StateNotifier<List<ReceiptEntity>> {
  static const String _storageKey = 'bee_user_receipts_v2';

  ReceiptsNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final list = decoded.map((e) => ReceiptEntity.fromJson(e as Map<String, dynamic>)).toList();
        state = list;
      }
    } catch (_) {}
  }

  Future<void> addReceipt(ReceiptEntity receipt) async {
    final current = state.where((r) => r.receiptId != receipt.receiptId).toList();
    final updated = [receipt, ...current];
    state = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(updated.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}
