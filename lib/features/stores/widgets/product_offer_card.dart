import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/product.dart';

/// Special offer card for products with active discounts
/// Features gradient backgrounds and prominent discount display
class ProductOfferCard extends StatelessWidget {
  const ProductOfferCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.persianIndigo,
              AppColors.mauve,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.persianIndigo.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surfaceSecondary,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.persianIndigo,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceSecondary,
                              child: Icon(
                                Icons.shopping_bag,
                                size: 40,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceSecondary,
                            child: Icon(
                              Icons.shopping_bag,
                              size: 40,
                              color: AppColors.textTertiary,
                            ),
                          ),
                  ),

                  const SizedBox(width: 16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.formattedDiscountPercentage,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.persianIndigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Product Name
                        Text(
                          product.name,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Price Row
                        Row(
                          children: [
                            // Original Price (struck through)
                            Text(
                              product.formattedPrice,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            
                            const SizedBox(width: 8),

                            // Discounted Price
                            Text(
                              product.formattedEffectivePrice,
                              style: AppTypography.h4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Offer ends text
                        if (product.discountEndDate != null)
                          Text(
                            _getTimeRemainingText(product.discountEndDate!),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
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

  /// Generate time remaining text for the offer
  String _getTimeRemainingText(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.inDays > 0) {
      return 'Oferta termina en ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'Oferta termina en ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'Oferta termina en ${difference.inMinutes} minutos';
    } else {
      return 'Oferta por terminar';
    }
  }
}

/// Compact horizontal offer card for scrollable lists
class ProductOfferCardCompact extends StatelessWidget {
  const ProductOfferCardCompact({
    super.key,
    required this.product,
    this.onTap,
    this.width = 280,
  });

  final Product product;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.persianIndigo,
              AppColors.mauve,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.persianIndigo.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      product.formattedDiscountPercentage,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.persianIndigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Product Image
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceSecondary,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.persianIndigo,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceSecondary,
                                child: Icon(
                                  Icons.shopping_bag,
                                  size: 32,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceSecondary,
                              child: Icon(
                                Icons.shopping_bag,
                                size: 32,
                                color: AppColors.textTertiary,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Product Name
                  Text(
                    product.name,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Price Row
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.formattedEffectivePrice,
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
