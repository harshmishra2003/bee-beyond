import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/entities/auth_state.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'route_paths.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authStateProvider,
      (previous, next) {
        if (previous?.status != next.status ||
            previous?.hasSeenOnboarding != next.hasSeenOnboarding) {
          notifyListeners();
        }
      },
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    final authState = _ref.read(authStateProvider);
    final status = authState.status;
    final hasSeenOnboarding = authState.hasSeenOnboarding;

    // While on splash screen, allow SplashScreen to manage initial navigation
    if (location == RoutePaths.splash) {
      return null;
    }

    // 1) Loading State -> Allow explicit navigation without forcing redirects
    if (status == AuthStatus.loading) {
      return null;
    }

    // 2) Unauthenticated State -> Auth Stack or Onboarding
    if (status == AuthStatus.unauthenticated) {
      // If user hasn't seen onboarding, force onboarding screen
      if (!hasSeenOnboarding) {
        return location == RoutePaths.onboarding ? null : RoutePaths.onboarding;
      }

      // If user has seen onboarding, allow access to Auth routes (login, register, forgot-password, otp)
      final isAuthRoute = location == RoutePaths.login ||
                          location == RoutePaths.register ||
                          location == RoutePaths.forgotPassword ||
                          location == RoutePaths.otp;

      if (isAuthRoute) {
        return null;
      }

      // Otherwise (trying to access protected AppStack route or splash/onboarding), redirect to Login
      return RoutePaths.login;
    }

    // 3) Authenticated State -> App Stack
    if (status == AuthStatus.authenticated) {
      // An authenticated user should NEVER be redirected to splash, onboarding, or auth screens
      final isAuthOrSplashRoute = location == RoutePaths.splash ||
                                  location == RoutePaths.onboarding ||
                                  location == RoutePaths.login ||
                                  location == RoutePaths.register ||
                                  location == RoutePaths.forgotPassword ||
                                  location == RoutePaths.otp;

      if (isAuthOrSplashRoute) {
        return RoutePaths.home;
      }

      // Otherwise, allow access to protected AppStack route
      return null;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
