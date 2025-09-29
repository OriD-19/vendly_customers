import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../models/store.dart';
import 'product_carousel.dart';
import 'store_info_widgets.dart';

/// Beautiful store card component displaying featured products and store info
class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, this.onTap});

  final Store store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      elevation: 4,
      shadowColor: AppColors.persianIndigo.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top half - Product Carousel
            ProductCarousel(products: store.carouselProducts, height: 160),

            // Bottom half - Store Information
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store name and category badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: AppTypography.h4.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            StoreCategoryBadge(
                              category: store.category,
                              isVerified: store.isVerified,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppTheme.spacingS),

                      // Store logo placeholder
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.persianIndigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                        ),
                        child: Icon(
                          _getStoreIcon(store.category),
                          color: AppColors.persianIndigo,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingS),

                  // Store description
                  Text(
                    store.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppTheme.spacingS),

                  // Rating
                  StoreRating(
                    rating: store.rating,
                    reviewCount: store.reviewCount,
                    showReviewCount: true,
                  ),

                  const SizedBox(height: AppTheme.spacingS),

                  // Status and delivery info
                  StoreStatusIndicator(
                    isOpen: store.isOpen,
                    deliveryInfo: store.deliveryInfo,
                  ),

                  const SizedBox(height: AppTheme.spacingS),

                  // Tags
                  if (store.tags.isNotEmpty)
                    SizedBox(
                      height: 20,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: store.tags.map((tag) {
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
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
      case 'belleza':
        return Icons.face;
      case 'hogar':
        return Icons.home;
      case 'deportes':
        return Icons.sports;
      case 'libros':
        return Icons.menu_book;
      case 'mascotas':
        return Icons.pets;
      default:
        return Icons.store;
    }
  }
}

/// Compact version of store card for horizontal lists
class StoreCardCompact extends StatelessWidget {
  const StoreCardCompact({
    super.key,
    required this.store,
    this.onTap,
    this.width = 160,
  });

  final Store store;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        margin: const EdgeInsets.only(right: AppTheme.spacingS),
        elevation: 2,
        shadowColor: AppColors.persianIndigo.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store image/icon
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.mauve.withOpacity(0.2),
                      AppColors.persianIndigo.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.borderRadiusMedium),
                    topRight: Radius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getStoreIcon(store.category),
                    color: AppColors.persianIndigo,
                    size: 32,
                  ),
                ),
              ),

              // Store info
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    Text(
                      store.category,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    StoreRating(
                      rating: store.rating,
                      reviewCount: store.reviewCount,
                      size: 12,
                      showReviewCount: false,
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
      case 'belleza':
        return Icons.face;
      case 'hogar':
        return Icons.home;
      case 'deportes':
        return Icons.sports;
      case 'libros':
        return Icons.menu_book;
      case 'mascotas':
        return Icons.pets;
      default:
        return Icons.store;
    }
  }
}
