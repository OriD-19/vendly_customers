import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../models/product.dart';
import '../services/store_data_service.dart';

/// Product detail screen showing full product information
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late PageController _imageController;
  int _currentImageIndex = 0;
  Product? product;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _loadProduct();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _loadProduct() {
    // Find the product from store data service
    final stores = StoreDataService.getAllStores();
    for (final store in stores) {
      for (final prod in store.featuredProducts) {
        if (prod.id == widget.productId) {
          setState(() {
            product = prod;
          });
          break;
        }
      }
      if (product != null) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Producto no encontrado'),
          backgroundColor: AppColors.surfacePrimary,
        ),
        body: const Center(
          child: Text('Producto no encontrado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      appBar: AppBar(
        title: Text(
          'Detalles del Producto',
          style: AppTypography.h3,
        ),
        backgroundColor: AppColors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add to favorites functionality
            },
            icon: const Icon(Icons.favorite_border, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Carousel
                  _buildImageCarousel(),

                  // Product Information
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductHeader(),
                        const SizedBox(height: 20),
                        _buildProductDescription(),
                        const SizedBox(height: 24),
                        _buildReviewsSection(),
                        const SizedBox(height: 24),
                        _buildSellerInformation(),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to Cart Button (Fixed at bottom)
          _buildAddToCartButton(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = product!.allImages;
    
    return Container(
      height: 300,
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                color: AppColors.surfaceSecondary,
              ),
              child: PageView.builder(
                controller: _imageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      color: AppColors.surfaceSecondary,
                    ),
                    child: Center(
                      child: Icon(
                        _getProductIcon(product!.category),
                        size: 120,
                        color: AppColors.persianIndigo.withOpacity(0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (images.length > 1) ...[
            const SizedBox(height: 16),
            // Image indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? AppColors.persianIndigo
                        : AppColors.borderColor,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product!.name,
          style: AppTypography.h2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product!.formattedPrice,
          style: AppTypography.h1.copyWith(
            color: AppColors.persianIndigo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product!.description,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        if (product!.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product!.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.persianIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.persianIndigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opiniones',
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Rating Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Row(
            children: [
              // Average Rating
              Column(
                children: [
                  Text(
                    product!.rating.toStringAsFixed(1),
                    style: AppTypography.h1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < product!.rating.floor()
                            ? Icons.star
                            : index < product!.rating
                                ? Icons.star_half
                                : Icons.star_border,
                        color: AppColors.warning,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product!.reviewCount} opiniones',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),

              // Rating Breakdown
              Expanded(
                child: Column(
                  children: [
                    for (int i = 5; i >= 1; i--)
                      _buildRatingBar(i, product!.ratingBreakdown[i] ?? 0),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Individual Reviews
        if (product!.reviews.isNotEmpty) ...[
          const SizedBox(height: 20),
          ...product!.reviews.take(2).map((review) => _buildReviewItem(review)),
          
          if (product!.reviews.length > 2)
            TextButton(
              onPressed: () {
                // TODO: Show all reviews
              },
              child: Text(
                'Ver todas las opiniones (${product!.reviews.length})',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.persianIndigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation(AppColors.persianIndigo),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.round()}%',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ProductReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.persianIndigo,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      review.formattedDate,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating.floor()
                    ? Icons.star
                    : Icons.star_border,
                color: AppColors.warning,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del Vendedor',
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.persianIndigo,
                child: Text(
                  product!.seller.name[0].toUpperCase(),
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product!.seller.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product!.seller.formattedRating,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: product!.inStock
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product!.name} agregado al carrito'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.persianIndigo,
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.persianIndigo,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Text(
              product!.inStock ? 'Agregar al Carrito' : 'Agotado',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pizza':
        return Icons.local_pizza;
      case 'frutas':
        return Icons.apple;
      case 'panadería':
        return Icons.bakery_dining;
      case 'lácteos':
        return Icons.local_drink;
      case 'camisetas':
        return Icons.checkroom;
      case 'pantalones':
        return Icons.dry_cleaning;
      case 'calzado':
        return Icons.sports_baseball;
      case 'smartphones':
        return Icons.smartphone;
      case 'accesorios':
        return Icons.headphones;
      case 'computadoras':
        return Icons.laptop;
      case 'suplementos':
        return Icons.medication;
      case 'instrumentos':
        return Icons.medical_services;
      case 'cuidado personal':
        return Icons.face;
      case 'coffee':
        return Icons.coffee;
      case 'bebidas':
        return Icons.local_cafe;
      default:
        return Icons.shopping_bag;
    }
  }
}