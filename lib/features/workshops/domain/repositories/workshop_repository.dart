import '../entities/workshop_item.dart';

abstract class WorkshopRepository {
  Future<List<WorkshopItem>> getWorkshops();
  Future<WorkshopItem?> getWorkshopDetail(String id);
}
