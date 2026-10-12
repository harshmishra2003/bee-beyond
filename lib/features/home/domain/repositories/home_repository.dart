import '../entities/banner_entity.dart';
import '../entities/category_entity.dart';

abstract class HomeRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<BannerEntity>> getBanners();
}
