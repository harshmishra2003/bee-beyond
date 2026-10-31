import '../../domain/entities/workshop_item.dart';
import '../../domain/repositories/workshop_repository.dart';
import '../datasources/workshop_remote_ds.dart';

class WorkshopRepositoryImpl implements WorkshopRepository {
  final WorkshopRemoteDataSource remoteDataSource;

  WorkshopRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<WorkshopItem>> getWorkshops() async {
    return await remoteDataSource.getWorkshops();
  }

  @override
  Future<WorkshopItem?> getWorkshopDetail(String id) async {
    return await remoteDataSource.getWorkshopDetail(id);
  }
}
