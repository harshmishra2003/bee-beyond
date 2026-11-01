import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/entities/auth_state.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'route_paths.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

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

  bool get isSplashFinished => true;

  void markSplashFinished() {
    notifyListeners();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    final authState = _ref.read(authStateProvider);
    final status = authState.status;
    final hasSeenOnboarding = authState.hasSeenOnboarding;

    debugPrint('[ROUTER] redirect eval: loc=$location, status=$status');

    // If Auth restoration is still in progress, remain on current screen
    if (status == AuthStatus.loading) {
      return null;
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
