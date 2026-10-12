import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  @override
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      OrderModel(
        orderId: 'ORD-998241',
        status: 'Delivered',
        totalAmount: 1298.0,
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        totalItems: 2,
      ),
      OrderModel(
        orderId: 'ORD-998105',
        status: 'Processing',
        totalAmount: 2499.0,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        totalItems: 1,
      ),
    ];
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    final orders = await getOrders();
    return orders.firstWhere((o) => o.orderId == id, orElse: () => orders.first);
  }
}
