import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/services_remote_ds.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/repositories/services_repository.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepositoryImpl(
    ServicesRemoteDataSourceImpl(ref.watch(dioClientProvider)),
  );
});

final servicesProvider = FutureProvider<List<ServiceItem>>((ref) async {
  return await ref.watch(servicesRepositoryProvider).getServices();
});
