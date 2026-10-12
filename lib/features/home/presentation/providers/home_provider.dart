import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/home_remote_ds.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_home_data_usecase.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(HomeRemoteDataSourceImpl());
});

final homeDataProvider = FutureProvider((ref) async {
  final useCase = GetHomeDataUseCase(ref.watch(homeRepositoryProvider));
  return await useCase.call();
});
