import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/stores/screens/store_detail_screen.dart';
import '../../features/stores/screens/product_detail_screen.dart';
import '../../features/categories/screens/category_products_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/cart/screens/checkout_screen.dart';
import '../../features/cart/screens/order_confirmation_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/cart/models/cart.dart';
import '../../shared/main_scaffold.dart';
import 'auth_guard.dart';

/// App routing configuration using GoRouter
class AppRouter {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String cart = '/cart';
  static const String storeDetail = '/store';
  static const String productDetail = '/product';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    debugLogDiagnostics: true,
    redirect: AuthGuard.redirectLogic,
    onException: (context, state, router) {
      // navigate to home as fallback
      router.go(home);
    },
    routes: [
      // authentication routes
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // onboarding route
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // checkout routes
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          // Get cart from extra data or create empty cart as fallback
          final cart = state.extra as Cart? ?? Cart(items: []);
          return CheckoutScreen(cart: cart);
        },
        routes: [
          GoRoute(
            path: 'confirmation',
            builder: (context, state) {
              // Get order details from extra data
              final orderData = state.extra as Map<String, dynamic>?;
              return OrderConfirmationScreen(
                orderNumber: orderData?['orderNumber'] as String?,
                totalAmount: orderData?['totalAmount'] as double?,
                orderDate: orderData?['orderDate'] as DateTime?,
              );
            },
          ),
        ],
      ),

      // main app shell with bottom navigation
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
          // cart route
          GoRoute(path: cart, builder: (context, state) => const CartScreen()),
        ],
      ),

      // store detail route (outside shell for proper navigation stack)
      GoRoute(
        name: 'store-detail',
        path: '/store/:storeId',
        builder: (context, state) {
          final storeId = state.pathParameters['storeId'];

          if (storeId == null) {
            return const Scaffold(
              body: Center(child: Text('Store ID is required')),
            );
          }

          return StoreDetailScreen(storeId: storeId);
        },
        routes: [
          GoRoute(
            name: 'product-detail',
            path: 'product/:productId',
            builder: (context, state) {
              final productId = state.pathParameters['productId'];

              if (productId == null) {
                return const Scaffold(
                  body: Center(child: Text('Product ID is required')),
                );
              }

              return ProductDetailScreen(productId: productId);
            },
          ),
          GoRoute(
            name: 'store-chat',
            path: 'chat',
            builder: (context, state) {
              final storeId = state.pathParameters['storeId'];
              final storeName = state.uri.queryParameters['storeName'] ?? 'Tienda';

              if (storeId == null) {
                return const Scaffold(
                  body: Center(child: Text('Store ID is required')),
                );
              }

              return ChatScreen(
                storeId: storeId,
                storeName: storeName,
              );
            },
          ),
        ],
      ),

      // category products route (outside shell for proper navigation stack)
      GoRoute(
        name: 'category-products',
        path: '/category/:categoryId/products',
        builder: (context, state) {
          final categoryIdStr = state.pathParameters['categoryId'];
          
          if (categoryIdStr == null) {
            return const Scaffold(
              body: Center(child: Text('Category ID is required')),
            );
          }

          final categoryId = int.tryParse(categoryIdStr);
          if (categoryId == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid Category ID')),
            );
          }

          return CategoryProductsScreen(categoryId: categoryId);
        },
      ),
    ],
  );
}
