import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bee_beeyond/core/constants/storage_keys.dart';
import 'package:bee_beeyond/core/network/dio_client.dart';
import 'package:bee_beeyond/core/network/interceptors/auth_interceptor.dart';
import 'package:bee_beeyond/core/network/interceptors/logging_interceptor.dart';
import 'package:bee_beeyond/core/services/secure_storage_service.dart';
import 'package:bee_beeyond/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:bee_beeyond/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bee_beeyond/features/auth/domain/entities/auth_state.dart';
import 'package:bee_beeyond/features/auth/domain/entities/user_entity.dart';
import 'package:bee_beeyond/features/auth/domain/repositories/auth_repository.dart';

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

// ─────────────────────────────────────────────
// AuthNotifier
// ─────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorageService _secureStorage;

  AuthNotifier(this._repository, this._secureStorage)
      : super(AuthState.loading()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    await _restoreSession();
  }

  // ─────────────────────────────────────────────
  // Session Restoration
  // ─────────────────────────────────────────────
  Future<void> _restoreSession() async {
    debugPrint('[AUTH] Restoring session via AuthRepository & SecureStorage...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding =
          prefs.getBool(StorageKeys.isOnboardingCompleted) ?? false;

      final currentUser = await _repository.getCurrentUser();

      if (currentUser == null) {
        debugPrint('[AUTH] No valid user session found → unauthenticated');
        state = AuthState.unauthenticated(hasSeenOnboarding: hasSeenOnboarding);
      } else {
        debugPrint('[AUTH] Session restored successfully for user: ${currentUser.name}');
        state = AuthState.authenticated(currentUser, hasSeenOnboarding: true);
      }
    } catch (e) {
      debugPrint('[AUTH] Restore session error: $e');
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        hasSeenOnboarding: true,
      );
    }
  }

  Future<void> _markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.isOnboardingCompleted, true);
    } catch (e) {
      debugPrint('[AUTH] Could not set onboarding status: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Auth Actions
  // ─────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    final user = await _repository.login(email, password);
    await _markOnboardingCompleted();
    state = AuthState.authenticated(user, hasSeenOnboarding: true);
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? dob,
    String? gender,
  }) async {
    final user = await _repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      dob: dob,
      gender: gender,
    );
    await _markOnboardingCompleted();
    state = AuthState.authenticated(user, hasSeenOnboarding: true);
  }

  Future<void> updateUser(UserEntity updatedUser) async {
    try {
      await _repository.updateUser(updatedUser);
      state = state.copyWith(user: updatedUser);
      debugPrint('[AUTH] User state updated: ${updatedUser.name}');
    } catch (e) {
      debugPrint('[AUTH] Error updating user: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    await _repository.forgotPassword(email);
  }

  Future<void> completeOnboarding() async {
    await _markOnboardingCompleted();
    state = state.copyWith(hasSeenOnboarding: true);
  }

  Future<void> logout() async {
    debugPrint('[AUTH] Logging out user...');
    try {
      await _repository.logout();
    } catch (e) {
      debugPrint('[AUTH] Repository logout error: $e');
    }

    try {
      await _secureStorage.clearAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.authToken);
      await prefs.remove(StorageKeys.userData);
      final hasSeenOnboarding =
          prefs.getBool(StorageKeys.isOnboardingCompleted) ?? true;

      state = AuthState.unauthenticated(hasSeenOnboarding: hasSeenOnboarding);
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        hasSeenOnboarding: true,
      );
    }
  }
}
