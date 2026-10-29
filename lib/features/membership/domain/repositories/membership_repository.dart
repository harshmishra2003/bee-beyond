import '../entities/membership_order_response_entity.dart';
import '../entities/membership_plan_entity.dart';

abstract class MembershipRepository {
  Future<List<MembershipPlanEntity>> getMembershipPlans();
  Future<MembershipPlanEntity?> getMembershipPlanDetail(String id);
  Future<MembershipOrderResponseEntity?> createMembershipOrder({
    required int planId,
    required String billingPeriod,
  });
  Future<bool> verifyMembershipPayment({
    required int membershipOrderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });
}
