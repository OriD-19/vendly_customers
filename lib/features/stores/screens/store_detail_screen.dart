import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../services/store_service.dart';
import '../services/product_service.dart';
import '../services/store_score_service.dart';
import '../widgets/store_info_widgets.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_offer_card.dart';

/// Store detail page showing full catalog and promotions
class StoreDetailScreen extends StatefulWidget {
  const StoreDetailScreen({super.key, required this.storeId});

  final String storeId;

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Store? store;
  List<Product> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Parse store ID
      final storeId = int.tryParse(widget.storeId);
      if (storeId == null) {
        setState(() {
          isLoading = false;
          error = 'ID de tienda inválido';
        });
        return;
      }

      // Fetch store details, products, and score in parallel
      final results = await Future.wait([
        StoreService.getStoreById(storeId),
        ProductService.getProductsByStore(storeId: storeId, skip: 0, limit: 100),
        StoreScoreService.getStoreScores(skip: 0, limit: 100),
      ]);

      final storeResult = results[0] as StoreDetailResult;
      final productResult = results[1] as ProductResult;
      final scoreResult = results[2] as StoreScoreResult;

      if (mounted) {
        setState(() {
          isLoading = false;
          
          if (!storeResult.success) {
            error = storeResult.error ?? 'Error al cargar la tienda';
          } else if (!productResult.success) {
            // Store loaded but products failed - show store anyway
            store = storeResult.store;
            
            // Apply score if available
            if (scoreResult.success) {
              final storeScore = scoreResult.getScoreForStore(storeId);
              if (storeScore != null && storeScore.hasReviews) {
                store = store!.copyWith(
                  rating: storeScore.averageRating,
                  reviewCount: storeScore.totalReviews,
                );
              }
            }
            
            error = productResult.error;
          } else {
            store = storeResult.store;
            products = productResult.products;
            
            // Apply score if available
            if (scoreResult.success) {
              final storeScore = scoreResult.getScoreForStore(storeId);
              if (storeScore != null && storeScore.hasReviews) {
                store = store!.copyWith(
                  rating: storeScore.averageRating,
                  reviewCount: storeScore.totalReviews,
                );
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          error = 'Error de conexión: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null && store == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadStoreData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.persianIndigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (store == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tienda no encontrada')),
        body: const Center(
          child: Text('La tienda no existe o no está disponible'),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Store Header
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.persianIndigo,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.persianIndigo, AppColors.mauve],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Store Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _getStoreIcon(store!.category),
                              size: 50,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Store Name
                          Text(
                            store!.name,
                            style: AppTypography.h2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Store Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StoreRating(
                                rating: store!.rating,
                                reviewCount: store!.reviewCount,
                                size: 16,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '• 1.2 mi',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${store!.category} • Abierto hasta las 8 PM',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Tab Bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderColor, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.persianIndigo,
                unselectedLabelColor: AppColors.textTertiary,
                indicatorColor: AppColors.persianIndigo,
                indicatorWeight: 3,
                labelStyle: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTypography.labelMedium,
                tabs: const [
                  Tab(text: 'Destacados'),
                  Tab(text: 'Catálogo'),
                  Tab(text: 'Opiniones'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FeaturedTab(store: store!, products: products),
                  _CatalogueTab(store: store!, products: products),
                  _ReviewsTab(store: store!),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating chat button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/store/${widget.storeId}/chat?storeName=${Uri.encodeComponent(store!.name)}',
          );
        },
        backgroundColor: AppColors.persianIndigo,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: Text(
          'Chat',
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _getStoreIcon(String category) {
    switch (category.toLowerCase()) {
      case 'comida':
        return Icons.restaurant;
      case 'supermercado':
        return Icons.local_grocery_store;
      case 'ropa':
        return Icons.checkroom;
      case 'tecnología':
        return Icons.devices;
      case 'farmacia':
        return Icons.local_pharmacy;
      default:
        return Icons.store;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

/// Featured tab with promotions and popular items
class _FeaturedTab extends StatelessWidget {
  const _FeaturedTab({required this.store, required this.products});

  final Store store;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    // Filter products with active offers
    final productsWithOffers = products.where((p) => p.hasValidDiscount).toList();
    
    // Get popular items (products with high ratings or featured products)
    final popularItems = products.take(10).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promotions Section (Products with active offers)
          if (productsWithOffers.isNotEmpty) ...[
            Text(
              'Ofertas Especiales',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...productsWithOffers.map((product) {
              return ProductOfferCard(
                product: product,
                onTap: () {
                  context.push('/store/${store.id}/product/${product.id}');
                },
              );
            }),
            const SizedBox(height: 32),
          ],

          // Popular Items Section
          if (popularItems.isNotEmpty) ...[
            Text(
              'Productos Populares',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...popularItems.map((product) {
              return ProductListItem(
                product: product,
                showBestSellerBadge: false,
                onTap: () {
                  context.push('/store/${store.id}/product/${product.id}');
                },
              );
            }),
          ],

          // Empty state
          if (products.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay productos disponibles',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Menu tab with full product catalog
class _CatalogueTab extends StatelessWidget {
  const _CatalogueTab({required this.store, required this.products});

  final Store store;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    // Group products by category
    final Map<String, List<Product>> productsByCategory = {};
    for (final product in products) {
      final category = product.category.isEmpty ? 'Sin categoría' : product.category;
      if (!productsByCategory.containsKey(category)) {
        productsByCategory[category] = [];
      }
      productsByCategory[category]!.add(product);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (products.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay productos disponibles',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Categories
            ...productsByCategory.entries.map((entry) {
              final categoryName = entry.key;
              final categoryProducts = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      categoryName,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ...categoryProducts.map((product) {
                    return ProductListItem(
                      product: product,
                      onTap: () {
                        context.push('/store/${store.id}/product/${product.id}');
                      },
                    );
                  }),

                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// Reviews tab (simplified for prototype)
class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'Opiniones próximamente',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
