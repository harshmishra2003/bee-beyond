import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppTransitionType {
  slideRight,
  slideUp,
  fadeScale,
}

/// Utility helper to build best-in-class screen transition animations with guaranteed unique & stable page keys
CustomTransitionPage<void> buildCustomTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  AppTransitionType type = AppTransitionType.slideRight,
  Duration duration = const Duration(milliseconds: 320),
}) {
  final pageKey = ValueKey('${state.pageKey.value}_${state.uri.toString()}');

  return CustomTransitionPage<void>(
    key: pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curveAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      switch (type) {
        case AppTransitionType.slideRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0.0),
              end: Offset.zero,
            ).animate(curveAnimation),
            child: FadeTransition(
              opacity: curveAnimation,
              child: child,
            ),
          );

        case AppTransitionType.slideUp:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(curveAnimation),
            child: FadeTransition(
              opacity: curveAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(curveAnimation),
                child: child,
              ),
            ),
          );

        case AppTransitionType.fadeScale:
          return FadeTransition(
            opacity: curveAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curveAnimation),
              child: child,
            ),
          );
      }
    },
  );
}

/// Helper for building smooth PageRouteTransitions for Navigator.push calls
PageRouteBuilder<T> buildSmoothPageRoute<T>({
  required Widget page,
  AppTransitionType type = AppTransitionType.slideUp,
  Duration duration = const Duration(milliseconds: 350),
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curveAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      switch (type) {
        case AppTransitionType.slideRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0.0),
              end: Offset.zero,
            ).animate(curveAnimation),
            child: FadeTransition(
              opacity: curveAnimation,
              child: child,
            ),
          );

        case AppTransitionType.slideUp:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(curveAnimation),
            child: FadeTransition(
              opacity: curveAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(curveAnimation),
                child: child,
              ),
            ),
          );

        case AppTransitionType.fadeScale:
          return FadeTransition(
            opacity: curveAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curveAnimation),
              child: child,
            ),
          );
      }
    },
  );
}
