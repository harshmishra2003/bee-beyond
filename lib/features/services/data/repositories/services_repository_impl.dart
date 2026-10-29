import '../../domain/entities/service_item.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_ds.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;

  ServicesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ServiceItem>> getServices() async {
    return await remoteDataSource.getServices();
  }
}
