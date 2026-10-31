import '../../domain/entities/membership_order_response_entity.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../../domain/entities/membership_verify_result_entity.dart';
import '../../domain/repositories/membership_repository.dart';
import '../../presentation/providers/expiry_provider.dart';
import '../datasources/membership_remote_ds.dart';

class MembershipRepositoryImpl implements MembershipRepository {
  final MembershipRemoteDataSource remoteDataSource;

  MembershipRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MembershipPlanEntity>> getMembershipPlans() async {
    return await remoteDataSource.getMembershipPlans();
  }

  @override
  Future<MembershipPlanEntity?> getMembershipPlanDetail(String id) async {
    return await remoteDataSource.getMembershipPlanDetail(id);
  }

  @override
  Future<UserPassSubscription?> getActiveUserMembership() async {
    return await remoteDataSource.getActiveUserMembership();
  }

  @override
  Future<MembershipOrderResponseEntity?> createMembershipOrder({
    required int planId,
    required String billingPeriod,
  }) async {
    return await remoteDataSource.createMembershipOrder(
      planId: planId,
      billingPeriod: billingPeriod,
    );
  }

  @override
  Future<MembershipVerifyResultEntity?> verifyMembershipPayment({
    required int membershipOrderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    return await remoteDataSource.verifyMembershipPayment(
      membershipOrderId: membershipOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      razorpaySignature: razorpaySignature,
    );
  }
}