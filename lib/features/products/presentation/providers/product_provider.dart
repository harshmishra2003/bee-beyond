import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/product_remote_ds.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ProductRemoteDataSourceImpl());
});

final allProductsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  return await ref.watch(productRepositoryProvider).getProducts();
});

final productDetailProvider = FutureProvider.family<ProductEntity, String>((ref, id) async {
  return await ref.watch(productRepositoryProvider).getProductById(id);
});
