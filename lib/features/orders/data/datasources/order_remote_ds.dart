import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel?> getOrderById(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient? _dioClient;

  OrderRemoteDataSourceImpl([this._dioClient]);

  Dio get _dio =>
      _dioClient?.instance ??
      Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  @override
  Future<List<OrderModel>> getOrders() async {
    final candidateEndpoints = [
      ApiEndpoints.orders, // '/orders.php'
      'https://metricstestingapp.xyz/api/orders.php',
      '/orders.php',
      '/orders',
      '/user/orders.php',
    ];

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await _dio.get(
          endpoint,
          queryParameters: {
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          final List<dynamic> list = rawData is Map
              ? (rawData['data'] ?? rawData['orders'] ?? rawData['items'] ?? [])
              : (rawData is List ? rawData : []);

          if (list.isNotEmpty) {
            return list
                .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }

    // Returns empty list when user has no API orders yet (Zero dummy data)
    return [];
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    try {
      final response = await _dio.get(
        '/order_details.php',
        queryParameters: {'id': id, '_t': DateTime.now().millisecondsSinceEpoch},
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic raw = response.data;
        if (raw is String) raw = jsonDecode(raw);
        final Map<String, dynamic> data =
            raw is Map ? (raw['data'] is Map ? raw['data'] : raw) : {};

        if (data.isNotEmpty) {
          return OrderModel.fromJson(data);
        }
      }
    } catch (_) {}

    final orders = await getOrders();
    return orders.firstWhere((o) => o.orderId == id, orElse: () => orders.first);
  }
}
