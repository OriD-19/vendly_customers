import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/stores/screens/store_detail_screen.dart';
import '../../shared/main_scaffold.dart';

/// App routing configuration using GoRouter
class AppRouter {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String storeDetail = '/store';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    debugLogDiagnostics: true,
    routes: [
      // Authentication Routes
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Onboarding Route
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Store Detail Route (outside shell for full screen)
      GoRoute(
        name: 'store-detail',
        path: '/store/:storeId',
        builder: (context, state) {
          final storeId = state.pathParameters['storeId'];
          print('Building StoreDetailScreen for storeId: $storeId'); // Debug log
          
          if (storeId == null) {
            return const Scaffold(
              body: Center(child: Text('Store ID is required')),
            );
          }
          
          return StoreDetailScreen(storeId: storeId);
        },
      ),

      // Debug test route
      GoRoute(
        path: '/test',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Test Route')),
          body: const Center(
            child: Text('Test route works!'),
          ),
        ),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(path: home, builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: orders,
            builder: (context, state) => const OrdersScreen(),
          ),
        ],
      ),
    ],
  );
}
