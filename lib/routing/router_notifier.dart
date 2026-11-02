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
    debugPrint('[ROUTER] RouterNotifier constructed');
    _ref.listen<AuthState>(
      authStateProvider,
      (previous, next) {
        debugPrint('[ROUTER] authState changed: status=${next.status}');
        notifyListeners();
      },
    );
  }

  bool get isSplashFinished => _isSplashFinished;

  void markSplashFinished() {
    if (!_isSplashFinished) {
      _isSplashFinished = true;
      debugPrint('[ROUTER] markSplashFinished() called.');
      notifyListeners();
    }
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    final authState = _ref.read(authStateProvider);
    final status = authState.status;
    final hasSeenOnboarding = authState.hasSeenOnboarding;

    debugPrint('[ROUTER] redirect eval: loc=$location, splashFinished=$_isSplashFinished, status=$status');

    // While 2.5s Dart splash timer is active or Auth is loading, remain on splash
    if (!_isSplashFinished || status == AuthStatus.loading) {
      if (location == RoutePaths.splash) {
        return null;
      }
      return RoutePaths.splash;
    }

    if (location == RoutePaths.splash) {
      if (status == AuthStatus.authenticated) {
        return RoutePaths.home;
      }
      if (status == AuthStatus.unauthenticated && !hasSeenOnboarding) {
        return RoutePaths.onboarding;
      }
      return RoutePaths.login;
    }

    // 1) Unauthenticated State -> Auth Stack or Onboarding
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

      debugPrint('[ROUTER] Unauthenticated -> Login');
      return RoutePaths.login;
    }

    // 2) Authenticated State -> Home App Stack
    if (status == AuthStatus.authenticated) {
      final isAuthOrSplashRoute = location == RoutePaths.splash ||
                                  location == RoutePaths.onboarding ||
                                  location == RoutePaths.login ||
                                  location == RoutePaths.register ||
                                  location == RoutePaths.forgotPassword ||
                                  location == RoutePaths.otp;

      if (isAuthOrSplashRoute) {
        debugPrint('[ROUTER] Authenticated -> Home');
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
