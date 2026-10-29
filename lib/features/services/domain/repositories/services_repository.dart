import '../entities/service_item.dart';

abstract class ServicesRepository {
  Future<List<ServiceItem>> getServices();
}
