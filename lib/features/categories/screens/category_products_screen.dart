import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../stores/models/product.dart';
import '../../stores/services/product_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/category.dart';
import '../services/category_service.dart';

/// Screen to display products filtered by category
class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _products = [];
  Category? _category;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalProducts = 0;
  final int _itemsPerPage = 20;
  bool _hasMoreProducts = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategoryDetails();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreProducts) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadCategoryDetails() async {
    try {
      final result = await CategoryService.getCategoryById(widget.categoryId);
      if (result.success && result.category != null) {
        setState(() {
          _category = result.category;
        });
      }
    } catch (e) {
      // Category details are optional, just continue
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _products = [];
        _currentPage = 1;
        _hasMoreProducts = true;
      }
    });

    final skip = (_currentPage - 1) * _itemsPerPage;
    final result = await ProductService.getProductsByCategory(
      categoryId: widget.categoryId,
      skip: skip,
      limit: _itemsPerPage,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;

        if (result.success) {
          if (refresh) {
            _products = result.products;
          } else {
            _products.addAll(result.products);
          }
          _totalProducts = result.total ?? 0;
          _hasMoreProducts = result.products.length >= _itemsPerPage;
        } else {
          _error = result.error;
        }
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    _currentPage++;
    await _loadProducts();
  }

  Future<void> _onRefresh() async {
    await _loadProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_category?.name ?? 'Productos'),
        backgroundColor: AppColors.surfacePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _products.isEmpty) {
      return _buildErrorState();
    }

    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          // Category header with product count
          if (_category != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceSecondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_category!.description != null && _category!.description!.isNotEmpty)
                    Text(
                      _category!.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '$_totalProducts ${_totalProducts == 1 ? 'producto' : 'productos'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

          // Products grid
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _products.length + (_hasMoreProducts ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _products.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final product = _products[index];
                return _ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
              _error ?? 'Error al cargar productos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadProducts(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.persianIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay productos en esta categoría',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta explorar otras categorías',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product card widget for the grid
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to product detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto: ${product.name}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceSecondary,
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surfaceSecondary,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.persianIndigo,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceSecondary,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                  ),

                  // Availability badge
                  if (!product.isAvailable)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'No disponible',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),

                    // Price and rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.persianIndigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.rating > 0) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (product.reviewCount > 0) ...[
                                const SizedBox(width: 2),
                                Text(
                                  '(${product.reviewCount})',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
