import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/entities/auth_state.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'route_paths.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isSplashFinished = false;

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

  void markSplashFinished() {
    if (!_isSplashFinished) {
      _isSplashFinished = true;
      debugPrint('[ROUTER] Splash screen finished. Triggering router redirect.');
      notifyListeners();
    }
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    final authState = _ref.read(authStateProvider);
    final status = authState.status;
    final hasSeenOnboarding = authState.hasSeenOnboarding;

    // 1) While splash screen timer hasn't finished, stay on splash screen
    if (!_isSplashFinished && location == RoutePaths.splash) {
      return null;
    }

    // 2) If on splash screen and splash timer is done
    if (location == RoutePaths.splash) {
      if (status == AuthStatus.loading) {
        return null; // Wait for auth restoration if still loading
      }
      if (status == AuthStatus.authenticated) {
        debugPrint('[ROUTER] Redirecting from Splash -> Home');
        return RoutePaths.home;
      }
      if (!hasSeenOnboarding) {
        debugPrint('[ROUTER] Redirecting from Splash -> Onboarding');
        return RoutePaths.onboarding;
      }
      debugPrint('[ROUTER] Redirecting from Splash -> Login');
      return RoutePaths.login;
    }

    // 3) Loading State -> Prevent deep links from bypassing splash
    if (status == AuthStatus.loading) {
      return RoutePaths.splash;
    }

    // 4) Unauthenticated State -> Auth Stack or Onboarding
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

    // 5) Authenticated State -> App Stack
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
