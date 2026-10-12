import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/order_remote_ds.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(OrderRemoteDataSourceImpl());
});

final ordersListProvider = FutureProvider<List<OrderEntity>>((ref) async {
  return await ref.watch(orderRepositoryProvider).getOrders();
});

final orderDetailProvider = FutureProvider.family<OrderEntity, String>((ref, id) async {
  return await ref.watch(orderRepositoryProvider).getOrderById(id);
});
