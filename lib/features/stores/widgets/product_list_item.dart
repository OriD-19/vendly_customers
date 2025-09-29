import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../models/product.dart';

/// Product list item component for store catalog
class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.product,
    this.onTap,
    this.showBestSellerBadge = false,
  });

  final Product product;
  final VoidCallback? onTap;
  final bool showBestSellerBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(color: AppColors.borderColor, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getProductIcon(product.category),
                    size: 32,
                    color: AppColors.persianIndigo.withOpacity(0.6),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        if (showBestSellerBadge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.persianIndigo,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BEST SELLER',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Product Description
                    Text(
                      product.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Price and Stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.persianIndigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (!product.inStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Add Button
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: product.inStock
                      ? AppColors.persianIndigo
                      : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  onPressed: product.inStock
                      ? () {
                          // TODO: Add to cart functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} agregado al carrito',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
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

/// Compact product item for horizontal lists
class ProductItemCompact extends StatelessWidget {
  const ProductItemCompact({
    super.key,
    required this.product,
    this.onTap,
    this.width = 140,
  });

  final Product product;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.borderRadiusMedium),
                    topRight: Radius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getProductIcon(product.category),
                    size: 24,
                    color: AppColors.persianIndigo,
                  ),
                ),
              ),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      product.formattedPrice,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.persianIndigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
