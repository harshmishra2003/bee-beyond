import '../../domain/entities/workshop_item.dart';
import '../../domain/entities/workshop_order_response_entity.dart';
import '../../domain/entities/workshop_verify_payment_response_entity.dart';
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

  @override
  Future<WorkshopOrderResponseEntity> createWorkshopOrder({
    required int workshopId,
    required String attendeeName,
    required String attendeeEmail,
    required String attendeePhone,
    String? specialNote,
  }) async {
    return await remoteDataSource.createWorkshopOrder(
      workshopId: workshopId,
      attendeeName: attendeeName,
      attendeeEmail: attendeeEmail,
      attendeePhone: attendeePhone,
      specialNote: specialNote,
    );
  }

  @override
  Future<WorkshopVerifyPaymentResponseEntity> verifyWorkshopPayment({
    required int workshopOrderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    return await remoteDataSource.verifyWorkshopPayment(
      workshopOrderId: workshopOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      razorpaySignature: razorpaySignature,
    );
  }

  @override
  Future<WorkshopVerifyPaymentResponseEntity> getWorkshopOrderStatus({
    required int workshopOrderId,
  }) async {
    return await remoteDataSource.getWorkshopOrderStatus(
      workshopOrderId: workshopOrderId,
    );
  }
}
