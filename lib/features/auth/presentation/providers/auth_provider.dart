import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/interceptors/auth_interceptor.dart';
import '../../../../core/network/interceptors/logging_interceptor.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/datasources/auth_remote_ds.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    authInterceptor: AuthInterceptor(
      ref.watch(secureStorageProvider),
      onUnauthorized: () {
        ref.read(authStateProvider.notifier).logout();
      },
    ),
    loggingInterceptor: LoggingInterceptor(),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(
      ref.watch(dioClientProvider),
      ref.watch(secureStorageProvider),
    ),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final StateNotifierProvider<AuthNotifier, AuthState> authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorageService _secureStorage;

  AuthNotifier(this._repository, this._secureStorage) : super(AuthState.loading()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    state = AuthState.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(StorageKeys.isOnboardingCompleted) ?? false;

      final token = await _secureStorage.getAuthToken().timeout(
        const Duration(seconds: 1),
        onTimeout: () => null,
      );

      if (token != null && token.trim().isNotEmpty) {
        UserEntity? user;
        try {
          user = await _repository.getCurrentUser().timeout(
            const Duration(seconds: 1),
            onTimeout: () => null,
          );
        } catch (_) {
          user = null;
        }

        if (user != null) {
          if (!hasSeenOnboarding) {
            await prefs.setBool(StorageKeys.isOnboardingCompleted, true);
          }
          state = AuthState.authenticated(user, hasSeenOnboarding: true);
          return;
        }
      }

      state = AuthState.unauthenticated(hasSeenOnboarding: hasSeenOnboarding);
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated, user: null, hasSeenOnboarding: false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _repository.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.isOnboardingCompleted, true);

      state = AuthState.authenticated(user, hasSeenOnboarding: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? dob,
    String? gender,
  }) async {
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        dob: dob,
        gender: gender,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.isOnboardingCompleted, true);

      state = AuthState.authenticated(user, hasSeenOnboarding: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _repository.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isOnboardingCompleted, true);

    state = state.copyWith(hasSeenOnboarding: true);
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(StorageKeys.isOnboardingCompleted) ?? true;

    state = AuthState.unauthenticated(hasSeenOnboarding: hasSeenOnboarding);
  }
}
