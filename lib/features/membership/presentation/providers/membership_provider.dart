import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/membership_remote_ds.dart';
import '../../data/repositories/membership_repository_impl.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../../domain/repositories/membership_repository.dart';

final membershipRemoteDataSourceProvider = Provider<MembershipRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MembershipRemoteDataSourceImpl(dioClient);
});

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final remoteDs = ref.watch(membershipRemoteDataSourceProvider);
  return MembershipRepositoryImpl(remoteDs);
});

final membershipPlansProvider =
    FutureProvider<List<MembershipPlanEntity>>((ref) async {
  final repo = ref.watch(membershipRepositoryProvider);
  return await repo.getMembershipPlans();
});

final membershipPlanDetailProvider = FutureProvider.family<MembershipPlanEntity, String>((ref, planId) async {
  final repo = ref.watch(membershipRepositoryProvider);
  final detail = await repo.getMembershipPlanDetail(planId);
  if (detail != null) return detail;
  final plans = await repo.getMembershipPlans();
  return plans.firstWhere((p) => p.id == planId, orElse: () => plans.first);
});
