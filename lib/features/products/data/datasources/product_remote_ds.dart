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

  @override
  Future<List<ProductModel>> getProducts() async {
    final dio = _dioClient;
    if (dio != null) {
      try {
        final response = await dio.get(ApiEndpoints.products);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          final List<dynamic> list = data is Map
              ? (data['data'] ?? data['products'] ?? [])
              : (data is List ? data : []);

          return list
              .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final dio = _dioClient;
    if (dio != null) {
      try {
        final response = await dio.get('${ApiEndpoints.productDetail}$id');
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          final Map<String, dynamic> json =
              data is Map ? (data['data'] ?? data) : {};
          return ProductModel.fromJson(json);
        }
      } catch (_) {}
    }

    final products = await getProducts();
    return products.firstWhere(
      (p) => p.id == id,
      orElse: () => ProductModel(
        id: id,
        title: 'Product Details',
        description: 'Details for this product will be loaded dynamically.',
        category: 'Store',
        imageUrl: '',
        price: 0.0,
      ),
    );
  }
}
