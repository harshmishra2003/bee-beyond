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

    // While on splash screen, allow SplashScreen to manage initial navigation timers & transition
    if (location == RoutePaths.splash) {
      return null;
    }

    // 1) Loading State -> Allow explicit navigation without forcing back to splash
    if (status == AuthStatus.loading) {
      return null;
    }

    // 2) Unauthenticated State -> Auth Stack
    if (status == AuthStatus.unauthenticated) {
      // If user hasn't seen onboarding, force onboarding
      if (!hasSeenOnboarding) {
        return location == RoutePaths.onboarding ? null : RoutePaths.onboarding;
      }

      // If already on an AuthStack route (login, register, forgot-password, otp), stay there
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

    // 3) Authenticated State -> App Stack / Onboarding
    if (status == AuthStatus.authenticated) {
      // If newly registered user needs onboarding before home
      if (!hasSeenOnboarding) {
        return location == RoutePaths.onboarding ? null : RoutePaths.onboarding;
      }

      // If trying to access any AuthStack route, splash, or onboarding -> redirect to Home
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
