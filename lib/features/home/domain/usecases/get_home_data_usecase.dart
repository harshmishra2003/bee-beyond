import '../entities/banner_entity.dart';
import '../entities/category_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<({List<CategoryEntity> categories, List<BannerEntity> banners})> call() async {
    final results = await Future.wait([
      repository.getCategories(),
      repository.getBanners(),
    ]);

    return (
      categories: results[0] as List<CategoryEntity>,
      banners: results[1] as List<BannerEntity>,
    );
  }
}
