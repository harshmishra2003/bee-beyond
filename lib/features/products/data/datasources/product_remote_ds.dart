import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient? _dioClient;

  ProductRemoteDataSourceImpl([this._dioClient]);

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
  Future<List<ProductModel>> getProducts() async {
    final candidateEndpoints = [
      ApiEndpoints.products, // '/products.php'
      'https://metricstestingapp.xyz/api/products.php',
      '/products.php',
      '/products',
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
              ? (rawData['data'] ?? rawData['products'] ?? rawData['items'] ?? [])
              : (rawData is List ? rawData : []);

          if (list.isNotEmpty) {
            return list
                .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }

    return [];
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final candidateEndpoints = [
      '${ApiEndpoints.productDetail}?id=$id', // '/product_details.php?id=1'
      'https://metricstestingapp.xyz/api/product_details.php?id=$id',
      '/product_details.php?id=$id',
      '/product_details.php',
      '/products/$id',
    ];

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await _dio.get(
          endpoint,
          queryParameters: {
            if (!endpoint.contains('id=')) 'id': id,
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          final Map<String, dynamic> json = rawData is Map
              ? (rawData['data'] is Map ? rawData['data'] : rawData)
              : {};

          if (json.isNotEmpty) {
            return ProductModel.fromJson(json);
          }
        }
      } catch (_) {}
    }

    final products = await getProducts();
    return products.firstWhere(
      (p) => p.id == id,
      orElse: () => ProductModel(
        id: id,
        title: 'Organic Healing Product',
        description: 'Authentic certified Ayurvedic remedy.',
        category: 'Store',
        imageUrl: '',
        price: 0.0,
      ),
    );
  }
}
