import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../shared/main_scaffold.dart';

/// App routing configuration using GoRouter
class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String search = '/search';
  static const String orders = '/orders';

  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    routes: [
      // Onboarding Route
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomeScreen(),
          ),
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