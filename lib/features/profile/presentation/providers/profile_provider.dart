import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final profileProvider = Provider<AsyncValue<UserEntity>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;

  if (authState.status == AuthStatus.authenticated && user != null) {
    return AsyncValue<UserEntity>.data(user);
  } else if (authState.status == AuthStatus.loading) {
    return const AsyncValue<UserEntity>.loading();
  }

  return AsyncValue<UserEntity>.error("User not logged in", StackTrace.current);
});
