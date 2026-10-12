import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      ProductModel(
        id: 'p_1',
        title: 'Rescue Remedy - Bach Flower Essence Drop (30ml)',
        description: 'Natural stress relief formulation made from natural Bach flowers.',
        category: 'Bach Flower',
        price: 799.0,
        originalPrice: 999.0,
        imageUrl: 'https://images.unsplash.com/photo-1608248597263-000799965d83?auto=format&fit=crop&w=600&q=80',
      ),
      ProductModel(
        id: 'p_2',
        title: 'Ayurvedic Herbal Healing Tea Blend (200g)',
        description: 'Prakriti balancing organic tea with Ashwagandha, Brahmi & Tulsi.',
        category: 'Ayurvedic Upchar',
        price: 499.0,
        originalPrice: 650.0,
        imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
      ),
      ProductModel(
        id: 'p_3',
        title: 'Bach Flower Remedy Guide Book (Hardcover)',
        description: 'Comprehensive practitioner book covering all 38 remedies with case examples.',
        category: 'Books',
        price: 1299.0,
        imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
      ),
    ];
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final products = await getProducts();
    return products.firstWhere((p) => p.id == id, orElse: () => products.first);
  }
}
