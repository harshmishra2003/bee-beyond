import '../entities/workshop_item.dart';
import '../entities/workshop_order_response_entity.dart';
import '../entities/workshop_verify_payment_response_entity.dart';

abstract class WorkshopRepository {
  Future<List<WorkshopItem>> getWorkshops();
  Future<WorkshopItem?> getWorkshopDetail(String id);

  Future<WorkshopOrderResponseEntity> createWorkshopOrder({
    required int workshopId,
    required String attendeeName,
    required String attendeeEmail,
    required String attendeePhone,
    String? specialNote,
  });

  Future<WorkshopVerifyPaymentResponseEntity> verifyWorkshopPayment({
    required int workshopOrderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });

  Future<WorkshopVerifyPaymentResponseEntity> getWorkshopOrderStatus({
    required int workshopOrderId,
  });
}
