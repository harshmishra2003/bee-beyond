import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/interceptors/auth_interceptor.dart';
import '../../../../core/network/interceptors/logging_interceptor.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/datasources/auth_remote_ds.dart';
import '../../data/models/user_model.dart';
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
    debugPrint('[AUTH] Authentication restoration started');
    debugPrint('[AUTH] Authentication state: loading');
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw TimeoutException('SharedPreferences timeout'),
      );
      final hasSeenOnboarding = prefs.getBool(StorageKeys.isOnboardingCompleted) ?? true;

      final token = prefs.getString(StorageKeys.authToken);

      if (token != null && token.trim().isNotEmpty) {
        final userDataJson = prefs.getString(StorageKeys.userData);
        if (userDataJson != null && userDataJson.trim().isNotEmpty) {
          try {
            final userMap = jsonDecode(userDataJson.trim()) as Map<String, dynamic>;
            final user = UserModel.fromJson(userMap);
            debugPrint('[AUTH] Authentication state: authenticated');
            state = AuthState.authenticated(user, hasSeenOnboarding: true);
            return;
          } catch (_) {
            debugPrint('[AUTH] Failed to parse user data');
          }
        }
      }

      debugPrint('[AUTH] Authentication state: unauthenticated');
      state = AuthState.unauthenticated(hasSeenOnboarding: hasSeenOnboarding);
    } catch (e) {
      debugPrint('[AUTH ERROR] Restoration failed: $e');
      debugPrint('[AUTH] Authentication state: unauthenticated');
      state = const AuthState(status: AuthStatus.unauthenticated, user: null, hasSeenOnboarding: true);
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

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bee_active_vip_pass_v2');
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(StorageKeys.isOnboardingCompleted) ?? true;

    state = AuthState.unauthenticated(hasSeenOnboarding: hasSeenOnboarding);
  }
}
