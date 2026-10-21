import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_ds.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OrderEntity>> getOrders() async {
    return await remoteDataSource.getOrders();
  }

  @override
  Future<OrderEntity> getOrderById(String id) async {
    final item = await remoteDataSource.getOrderById(id);
    final OrderEntity fallback = OrderEntity(
      orderId: id,
      status: 'Processing',
      totalAmount: 0.0,
      orderDate: DateTime.now(),
      totalItems: 1,
    );
    final OrderEntity result = (item as OrderEntity?) ?? fallback;
    return result;
  }
}
