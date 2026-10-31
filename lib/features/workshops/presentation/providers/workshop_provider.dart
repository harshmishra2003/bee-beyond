import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/workshop_remote_ds.dart';
import '../../data/repositories/workshop_repository_impl.dart';
import '../../domain/entities/workshop_item.dart';
import '../../domain/repositories/workshop_repository.dart';

final workshopRepositoryProvider = Provider<WorkshopRepository>((ref) {
  return WorkshopRepositoryImpl(
    WorkshopRemoteDataSourceImpl(ref.watch(dioClientProvider)),
  );
});

final allWorkshopsProvider = FutureProvider<List<WorkshopItem>>((ref) async {
  return await ref.watch(workshopRepositoryProvider).getWorkshops();
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final workshopsByCategoryProvider = Provider<AsyncValue<List<WorkshopItem>>>((ref) {
  final allWorkshopsAsync = ref.watch(allWorkshopsProvider);
  final category = ref.watch(selectedCategoryProvider);

  return allWorkshopsAsync.whenData((workshops) {
    if (category == 'All') return workshops;
    return workshops.where((w) {
      final cat = w.category.toLowerCase();
      final filter = category.toLowerCase();
      return cat.contains(filter) || filter.contains(cat);
    }).toList();
  });
});

final workshopDetailProvider = FutureProvider.family<WorkshopItem?, String>((ref, id) async {
  return await ref.watch(workshopRepositoryProvider).getWorkshopDetail(id);
});
