import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/services/auth_service.dart';

/// Authentication guard for route redirection
/// Checks if user is logged in and redirects to appropriate screen
class AuthGuard {
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await AuthService.isLoggedIn();
  }

  /// Redirect callback for GoRouter
  /// Returns login path if not authenticated, null otherwise
  static Future<String?> redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isLoggedIn = await isAuthenticated();
    final isGoingToAuth = state.matchedLocation.startsWith('/auth') ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/onboarding';

    // If not logged in and trying to access protected route
    if (!isLoggedIn && !isGoingToAuth) {
      return '/login';
    }

    // If logged in and trying to access auth screens
    if (isLoggedIn && isGoingToAuth) {
      return '/home';
    }

    // No redirect needed
    return null;
  }

  /// Check authentication and show dialog if not logged in
  /// Returns true if authenticated, false otherwise
  static Future<bool> requireAuth(
    BuildContext context, {
    String? message,
  }) async {
    final isLoggedIn = await isAuthenticated();

    if (!isLoggedIn && context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Iniciar Sesión'),
          content: Text(
            message ?? 'Debes iniciar sesión para acceder a esta función',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/login');
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      );
    }

    return isLoggedIn;
  }
}

/// List of protected routes that require authentication
class ProtectedRoutes {
  static const List<String> routes = [
    '/cart',
    '/checkout',
    '/orders',
    '/order-confirmation',
    '/profile',
    '/addresses',
    '/favorites',
    '/settings',
  ];

  /// Check if a route is protected
  static bool isProtected(String path) {
    return routes.any((route) => path.startsWith(route));
  }
}

/// List of public routes accessible without authentication
class PublicRoutes {
  static const List<String> routes = [
    '/',
    '/home',
    '/login',
    '/register',
    '/onboarding',
    '/store',
    '/product',
    '/search',
  ];

  /// Check if a route is public
  static bool isPublic(String path) {
    return routes.any((route) => path.startsWith(route));
  }
}
