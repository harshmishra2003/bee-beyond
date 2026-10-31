import '../../../../core/constants/asset_paths.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<BannerModel>> getBanners();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async {
    return const [
      CategoryModel(
        id: 'cat_1',
        name: 'Ayurvedic Upchar',
        icon: 'spa',
        imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_2',
        name: 'Counselling',
        icon: 'psychology',
        imageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_3',
        name: 'Life Coaching',
        icon: 'self_improvement',
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_4',
        name: 'Alternative Drugless',
        icon: 'healing',
        imageUrl: AssetPaths.ancientHealing,
      ),
      CategoryModel(
        id: 'cat_5',
        name: 'Nutrition',
        icon: 'restaurant',
        imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_6',
        name: 'Graphology',
        icon: 'edit_note',
        imageUrl: 'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_7',
        name: 'Psychotherapy',
        icon: 'diversity_1',
        imageUrl: 'https://images.unsplash.com/photo-1527137342181-19aab11a8ee8?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_8',
        name: 'DMIT',
        icon: 'fingerprint',
        imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_9',
        name: 'Astrology',
        icon: 'auto_awesome',
        imageUrl: 'https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f5?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_10',
        name: 'Jain Mantra',
        icon: 'brightness_high',
        imageUrl: 'https://images.unsplash.com/photo-1609137149736-233816123139?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_11',
        name: 'Buddhism',
        icon: 'temple_buddhist',
        imageUrl: 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_12',
        name: 'Mind & Body Balance',
        icon: 'balance',
        imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_13',
        name: 'Spiritual Holistic',
        icon: 'filter_vintage',
        imageUrl: 'https://images.unsplash.com/photo-1519834785169-98be25ec3f84?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_14',
        name: 'Health, Wealth & Success',
        icon: 'stars',
        imageUrl: 'https://images.unsplash.com/photo-1499209974431-9dac3ada00d7?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_15',
        name: 'Aromatherapy',
        icon: 'bubble_chart',
        imageUrl: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_16',
        name: 'Personality & Motivation',
        icon: 'emoji_events',
        imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400&auto=format&fit=crop',
      ),
      CategoryModel(
        id: 'cat_17',
        name: 'Bach Flower Therapy',
        icon: 'local_florist',
        imageUrl: AssetPaths.bachFlower,
      ),
      CategoryModel(
        id: 'cat_18',
        name: 'Vastu Shastra',
        icon: 'home_work',
        imageUrl: AssetPaths.vastu,
      ),
    ];
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    return const [
      BannerModel(
        id: 'b_1',
        imageUrl: AssetPaths.vastu,
        title: 'Vastu Shastra - Harmonize Your Space & Energy',
      ),
      BannerModel(
        id: 'b_2',
        imageUrl: AssetPaths.ancientHealing,
        title: 'Ancient Healing Mastery - Secrets of Natural Cure',
      ),
      BannerModel(
        id: 'b_3',
        imageUrl: AssetPaths.banner3,
        title: 'Bee Beyonnd - Special Offers & Featured Posters',
      ),
      BannerModel(
        id: 'b_4',
        imageUrl: AssetPaths.banner4,
        title: 'Holistic Academy & Wellness Workshops',
      ),
      BannerModel(
        id: 'b_5',
        imageUrl: AssetPaths.bachFlower,
        title: 'Bach Flower Remedies - Natural Emotional Healing',
      ),
    ];
  }
}
