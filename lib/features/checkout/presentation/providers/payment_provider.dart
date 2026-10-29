import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/payment_remote_ds.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PaymentRepositoryImpl(PaymentRemoteDataSourceImpl(dioClient));
});
