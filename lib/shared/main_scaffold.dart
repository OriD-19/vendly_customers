import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/router/app_router.dart';
import '../features/cart/providers/cart_bloc.dart';
import '../features/cart/providers/cart_state.dart';

/// Main scaffold with bottom navigation for the app
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(location),
            onTap: (int index) => _onItemTapped(index, context),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search_outlined),
                activeIcon: const Icon(Icons.search),
                label: 'Buscar',
              ),
              BottomNavigationBarItem(
                icon: cartState.itemCount > 0
                    ? Badge(
                        label: Text('${cartState.itemCount}'),
                        child: const Icon(Icons.shopping_cart_outlined),
                      )
                    : const Icon(Icons.shopping_cart_outlined),
                activeIcon: cartState.itemCount > 0
                    ? Badge(
                        label: Text('${cartState.itemCount}'),
                        child: const Icon(Icons.shopping_cart),
                      )
                    : const Icon(Icons.shopping_cart),
                label: 'Carrito',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          );
        },
      ),
    );
  }

  static int _calculateSelectedIndex(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/cart':
        return 2;
      case '/orders':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.search);
        break;
      case 2:
        context.go(AppRouter.cart);
        break;
      case 3:
        context.go(AppRouter.orders);
        break;
    }
  }
}
