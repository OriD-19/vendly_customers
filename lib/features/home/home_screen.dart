import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/vendly_logo.dart';
import '../../shared/widgets/theme_widgets.dart';
import '../stores/services/store_service.dart';
import '../stores/services/store_score_service.dart';
import '../stores/models/store.dart';
import '../stores/widgets/store_card.dart';
import '../categories/services/category_service.dart';
import '../categories/models/category.dart';
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
            const ThemeToggleButton(), // Theme toggle button
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

class _CategoriesSection extends StatefulWidget {
  const _CategoriesSection();

  @override
  State<_CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<_CategoriesSection> {
  bool _isLoading = false;
  List<Category> _categories = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await CategoryService.getTopCategories(
        limit: 5,
        sortBy: 'count',
        sortOrder: 'desc',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result.success) {
            _categories = result.categories;
          } else {
            _error = result.error ?? 'Error al cargar categorías';
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_grocery_store':
        return Icons.local_grocery_store;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'checkroom':
        return Icons.checkroom;
      case 'devices':
        return Icons.devices;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'home':
        return Icons.home;
      case 'local_bar':
        return Icons.local_bar;
      case 'category':
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categorías', style: AppTypography.h3),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 32,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadCategories,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else if (_categories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No hay categorías disponibles',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final iconName = category.getIconName();
                final icon = _getIconData(iconName);

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _categories.length - 1 ? 16 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to category products screen
                      context.push('/category/${category.id}/products');
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.mauve.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.persianIndigo,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          child: Text(
                            category.name,
                            style: AppTypography.labelSmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
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
      final results = await Future.wait([
        StoreService.getAllStores(),
        StoreScoreService.getStoreScores(skip: 0, limit: 100),
      ]);

      final storeResult = results[0] as StoreResult;
      final scoreResult = results[1] as StoreScoreResult;

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (storeResult.success) {
            _stores = storeResult.stores;
            
            // Apply scores to stores if available
            if (scoreResult.success) {
              _stores = _stores.map((store) {
                final storeId = int.tryParse(store.id);
                if (storeId != null) {
                  final score = scoreResult.getScoreForStore(storeId);
                  if (score != null && score.hasReviews) {
                    return store.copyWith(
                      rating: score.averageRating,
                      reviewCount: score.totalReviews,
                    );
                  }
                }
                return store;
              }).toList();
            }
          } else {
            _error = storeResult.error ?? 'Error al cargar tiendas';
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
                context.pushNamed(
                  'store-detail',
                  pathParameters: {'storeId': storeId},
                );
              } catch (e) {
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

// class _PromotionsSection extends StatelessWidget {
//   const _PromotionsSection();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Promociones especiales', style: AppTypography.h3),
//         const SizedBox(height: 16),
//         Container(
//           height: 120,
//           decoration: BoxDecoration(
//             color: AppColors.surfaceSecondary,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Center(
//             child: Text('Ofertas del día', style: TextStyle(fontSize: 18)),
//           ),
//         ),
//       ],
//     );
//   }
// }
