import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_remote_ds.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ProfileRemoteDataSourceImpl());
});

final profileProvider = FutureProvider<ProfileEntity>((ref) async {
  return await ref.watch(profileRepositoryProvider).getProfile();
});
