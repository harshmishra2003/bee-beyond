import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/order_remote_ds.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'receipt_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return OrderRepositoryImpl(OrderRemoteDataSourceImpl(dioClient));
});

final ordersListProvider = FutureProvider<List<OrderEntity>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  final apiOrders = await repo.getOrders();
  final userReceipts = ref.watch(receiptsProvider);

  final List<OrderEntity> allCombined = [...apiOrders];

  for (final receipt in userReceipts) {
    if (!allCombined.any((o) => o.orderId == receipt.orderId || o.orderId == receipt.receiptId)) {
      allCombined.add(
        OrderEntity(
          orderId: receipt.orderId,
          status: 'Delivered',
          totalAmount: receipt.grandTotal,
          orderDate: receipt.date,
          totalItems: receipt.items.isNotEmpty ? receipt.items.length : 1,
        ),
      );
    }
  }

  allCombined.sort((a, b) => b.orderDate.compareTo(a.orderDate));
  return allCombined;
});

final orderDetailProvider = FutureProvider.family<OrderEntity, String>((ref, id) async {
  return await ref.watch(orderRepositoryProvider).getOrderById(id);
});
