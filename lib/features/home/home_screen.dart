import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/vendly_logo.dart';
import '../stores/services/store_service.dart';
import '../stores/models/store.dart';
import '../stores/widgets/store_card.dart';
import 'widgets/account_drawer.dart';

/// Home screen - Main landing page
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            VendlyLogo(height: 32, color: AppColors.persianIndigo),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Mi cuenta',
            ),
          ),
        ],
      ),
      endDrawer: const AccountDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const _WelcomeSection(),

            const SizedBox(height: 8),

            // Categories Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _CategoriesSection(),
            ),

            const SizedBox(height: 24),

            // Featured Stores Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiendas destacadas',
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Ver todas',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.persianIndigo,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Store Cards List
            _StoresList(),

            // Debug button
            const SizedBox(height: 24),

            // Promotions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _PromotionsSection(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola!',
            style: AppTypography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre productos increíbles de tus tiendas favoritas',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.restaurant, 'name': 'Comida'},
      {'icon': Icons.local_grocery_store, 'name': 'Market'},
      {'icon': Icons.local_pharmacy, 'name': 'Farmacia'},
      {'icon': Icons.checkroom, 'name': 'Ropa'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categorías', style: AppTypography.h3),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: categories.map((category) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mauve.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: AppColors.persianIndigo,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: AppTypography.labelSmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StoresList extends StatefulWidget {
  @override
  State<_StoresList> createState() => _StoresListState();
}

class _StoresListState extends State<_StoresList> {
  bool _isLoading = false;
  List<Store> _stores = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await StoreService.getAllStores();

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result.success) {
            _stores = result.stores;
          } else {
            _error = result.error ?? 'Error al cargar tiendas';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error de conexión: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStores,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_stores.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No hay tiendas disponibles',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600, // Max width per item
          mainAxisExtent: 380,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _stores.length,
        itemBuilder: (context, index) {
          return StoreCard(
            store: _stores[index],
            onTap: () {
              final storeId = _stores[index].id;
              final route = '/store/$storeId';
              try {
                // Try using context.pushNamed with named route
                context.pushNamed(
                  'store-detail',
                  pathParameters: {'storeId': storeId},
                );
              } catch (e) {
                // Fallback to context.push()
                try {
                  context.push(route);
                } catch (e2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al navegar a la tienda: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}

class _PromotionsSection extends StatelessWidget {
  const _PromotionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Promociones especiales', style: AppTypography.h3),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text('🎉 Ofertas del día', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}
