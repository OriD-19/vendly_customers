import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/store.dart';
import '../services/store_data_service.dart';
import '../widgets/store_info_widgets.dart';
import '../widgets/product_list_item.dart';
import '../widgets/promotion_card.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStoreData();
  }

  void _loadStoreData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    final storeData = StoreDataService.getStoreById(widget.storeId);
    setState(() {
      store = storeData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                  _FeaturedTab(store: store!),
                  _CatalogueTab(store: store!),
                  _ReviewsTab(store: store!),
                ],
              ),
            ),
          ],
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
  const _FeaturedTab({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final promotions = StoreDataService.getStorePromotions(store.id);
    final popularItems = store.featuredProducts;
    
    print('Store ${store.id}: Found ${promotions.length} promotions'); // Debug

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promotions Section
          if (promotions.isNotEmpty) ...[
            Text(
              'Ofertas Especiales',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 280, // Fixed width for promotion cards
                    child: PromotionCard(
                      promotion: promotions[index],
                      onTap: () {
                        // TODO: Handle promotion tap
                        print('Tapped promotion: ${promotions[index].title}');
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Popular Items Section
          Text(
            'Productos Populares',
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...popularItems.map((product) {
            return ProductListItem(
              product: product,
              showBestSellerBadge: true,
              onTap: () {
                context.go('/store/${store.id}/product/${product.id}');
              },
            );
          }),
        ],
      ),
    );
  }
}

/// Menu tab with full product catalog
class _CatalogueTab extends StatelessWidget {
  const _CatalogueTab({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final allProducts = StoreDataService.getStoreProducts(store.id);
    final categories = StoreDataService.getStoreCategories(store.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          ...categories.map((category) {
            final categoryProducts = allProducts
                .where((p) => p.category == category.name)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    category.name,
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ...categoryProducts.map((product) {
                  return ProductListItem(
                    product: product, 
                    onTap: () {
                      context.go('/store/${store.id}/product/${product.id}');
                    },
                  );
                }),

                const SizedBox(height: 16),
              ],
            );
          }),
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
