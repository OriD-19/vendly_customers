import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/product.dart';

/// Product carousel widget for store cards
class ProductCarousel extends StatefulWidget {
  const ProductCarousel({
    super.key, 
    required this.products, 
    this.height = 160,
    this.storeId,
    this.onProductTap,
  });

  final List<Product> products;
  final double height;
  final String? storeId;
  final Function(Product)? onProductTap;

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  final PageController _pageController = PageController(); // for the carousel swipe functionality
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Product Images Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              return _buildProductImage(widget.products[index]);
            },
          ),

          // Page Indicators (only show if more than 1 product)
          if (widget.products.length > 1)
            Positioned(
              bottom: AppTheme.spacingS,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.products.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

          // Product Info Overlay
          Positioned(
            top: AppTheme.spacingS,
            right: AppTheme.spacingS,
            child: _buildPriceTag(widget.products[_currentPage]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return GestureDetector(
      onTap: () {
        if (widget.onProductTap != null) {
          widget.onProductTap!(product);
        } else if (widget.storeId != null) {
          // Navigate to product detail within store context
          context.go('/store/${widget.storeId}/product/${product.id}');
        } else {
          // Fallback navigation (shouldn't normally happen)
          context.goNamed('product-detail', pathParameters: {'productId': product.id});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.borderRadiusLarge),
            topRight: Radius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
          // Placeholder for product image
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.mauve.withOpacity(0.1),
                  AppColors.persianIndigo.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                topRight: Radius.circular(AppTheme.borderRadiusLarge),
              ),
            ),
            child: Center(
              child: Icon(
                _getProductIcon(product.category),
                size: 48,
                color: AppColors.persianIndigo.withOpacity(0.6),
              ),
            ),
          ),

          // Gradient overlay for better text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                  topRight: Radius.circular(AppTheme.borderRadiusLarge),
                ),
              ),
            ),
          ),

          // Product name at bottom
          Positioned(
            bottom: AppTheme.spacingS,
            left: AppTheme.spacingS,
            right: 60, // Space for price tag
            child: Text(
              product.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTag(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.persianIndigo,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        product.formattedPrice,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadiusLarge),
          topRight: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppTheme.spacingS),
            Text(
              'No hay productos destacados',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
          ],
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
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
