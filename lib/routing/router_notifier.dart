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

    // 1) Loading State -> Prevent deep links from bypassing auth check
    if (status == AuthStatus.loading) {
      return location == RoutePaths.splash ? null : RoutePaths.splash;
    }

    // While on splash screen, allow SplashScreen to manage initial navigation
    if (location == RoutePaths.splash) {
      return null;
    }

    // 2) Unauthenticated State -> Auth Stack or Onboarding
    if (status == AuthStatus.unauthenticated) {
      if (!hasSeenOnboarding) {
        return location == RoutePaths.onboarding ? null : RoutePaths.onboarding;
      }

      final isAuthRoute = location == RoutePaths.login ||
                          location == RoutePaths.register ||
                          location == RoutePaths.forgotPassword ||
                          location == RoutePaths.otp;

      if (isAuthRoute) {
        return null;
      }

      debugPrint('[ROUTER] Navigation destination: ${RoutePaths.login}');
      return RoutePaths.login;
    }

    // 3) Authenticated State -> App Stack
    if (status == AuthStatus.authenticated) {
      final isAuthOrSplashRoute = location == RoutePaths.splash ||
                                  location == RoutePaths.onboarding ||
                                  location == RoutePaths.login ||
                                  location == RoutePaths.register ||
                                  location == RoutePaths.forgotPassword ||
                                  location == RoutePaths.otp;

      if (isAuthOrSplashRoute) {
        debugPrint('[ROUTER] Navigation destination: ${RoutePaths.home}');
        return RoutePaths.home;
      }

      return null;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
