import 'package:flutter/material.dart';

class AuthGuard {
  static bool isAuthenticated = false; // Mock / state reader

  static String? redirect(BuildContext context, String currentPath) {
    // If not authenticated and trying to access protected routes
    final protectedRoutes = [
      '/cart',
      '/checkout',
      '/orders',
      '/profile',
      '/courses/joined',
    ];

    if (!isAuthenticated && protectedRoutes.any((r) => currentPath.startsWith(r))) {
      return '/login';
    }

    return null;
  }
}
