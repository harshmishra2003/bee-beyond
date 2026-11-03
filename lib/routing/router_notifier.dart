import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/entities/auth_state.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'route_paths.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isSplashFinished = false;
  Timer? _splashSafetyTimer;

  RouterNotifier(this._ref) {
    debugPrint('[ROUTER] RouterNotifier constructed');
    _ref.listen<AuthState>(
      authStateProvider,
      (previous, next) {
        debugPrint('[ROUTER] authState changed: status=${next.status}');
        notifyListeners();
      },
    );

    // Safety fallback timer (1500ms max) ensuring router never hangs on splash
    _splashSafetyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!_isSplashFinished) {
        _isSplashFinished = true;
        debugPrint('[ROUTER] Safety fallback timer forced splash finish.');
        notifyListeners();
      }
    });
  }

  bool get isSplashFinished => _isSplashFinished;

  void markSplashFinished() {
    _splashSafetyTimer?.cancel();
    if (!_isSplashFinished) {
      _isSplashFinished = true;
      debugPrint('[ROUTER] markSplashFinished() called.');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _splashSafetyTimer?.cancel();
    super.dispose();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    final authState = _ref.read(authStateProvider);
    final status = authState.status;
    final hasSeenOnboarding = authState.hasSeenOnboarding;

    debugPrint('[ROUTER] redirect eval: loc=$location, splashFinished=$_isSplashFinished, status=$status');

    // While Dart splash display timer is active, remain on splash
    if (!_isSplashFinished) {
      if (location == RoutePaths.splash) {
        return null;
      }
      return RoutePaths.splash;
    }

    // Splash finished -> MUST transition away from /splash
    if (location == RoutePaths.splash) {
      if (status == AuthStatus.authenticated) {
        debugPrint('[ROUTER] Redirecting /splash -> /home');
        return RoutePaths.home;
      }
      if (status == AuthStatus.unauthenticated) {
        final target = hasSeenOnboarding ? RoutePaths.login : RoutePaths.onboarding;
        debugPrint('[ROUTER] Redirecting /splash -> $target');
        return target;
      }
      // Safety fallback if status is still loading when splash timer finishes
      final target = hasSeenOnboarding ? RoutePaths.login : RoutePaths.onboarding;
      debugPrint('[ROUTER] Splash finished while Auth loading -> Safety fallback redirect to $target');
      return target;
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
