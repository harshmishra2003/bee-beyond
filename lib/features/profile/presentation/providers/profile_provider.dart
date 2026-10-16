import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Since we have established a real Auth API that returns the User profile
// we will listen directly to the AuthState so the Profile is always dynamically in sync!

final profileProvider = Provider<AsyncValue<UserEntity>>((ref) {
  final authState = ref.watch(authStateProvider);
  
  if (authState is AsyncData && authState.value != null) {
    return AsyncValue.data(authState.value!);
  } else if (authState is AsyncLoading) {
    return const AsyncValue.loading();
  } else if (authState is AsyncError) {
    return AsyncValue.error(authState.error!, authState.stackTrace!);
  }
  
  return AsyncValue.error("User not logged in", StackTrace.current);
});
