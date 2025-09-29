import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/promotion.dart';

/// Promotion card widget for displaying store promotions
/// Features gradient backgrounds, icons, and promotion details
class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.promotion,
    this.onTap,
  });

  final Promotion promotion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _getPromotionColors(promotion.type);
    final icon = _getPromotionIcon(promotion.type);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 12,
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
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      if (promotion.discountText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            promotion.discountText,
                            style: TextStyle(
                              color: colors.first,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promotion.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      promotion.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  /// Get gradient colors based on promotion type
  List<Color> _getPromotionColors(PromotionType type) {
    switch (type) {
      case PromotionType.percentage:
        return [AppColors.persianIndigo, AppColors.mauve];
      case PromotionType.fixedAmount:
        return [AppColors.russianViolet, AppColors.indigo];
      case PromotionType.buyOneGetOne:
        return [AppColors.success, const Color(0xFF4CAF50)];
      case PromotionType.freeDelivery:
        return [const Color(0xFF2196F3), const Color(0xFF03DAC6)];
      case PromotionType.bundle:
        return [const Color(0xFFFF9800), const Color(0xFFFFC107)];
      case PromotionType.seasonal:
        return [const Color(0xFFE91E63), const Color(0xFF9C27B0)];
    }
  }

  /// Get icon based on promotion type
  IconData _getPromotionIcon(PromotionType type) {
    switch (type) {
      case PromotionType.percentage:
        return Icons.percent;
      case PromotionType.fixedAmount:
        return Icons.attach_money;
      case PromotionType.buyOneGetOne:
        return Icons.add_box;
      case PromotionType.freeDelivery:
        return Icons.local_shipping;
      case PromotionType.bundle:
        return Icons.inventory;
      case PromotionType.seasonal:
        return Icons.celebration;
    }
  }
}

/// Small promotion banner for lists
class PromotionBanner extends StatelessWidget {
  const PromotionBanner({
    super.key,
    required this.promotion,
    this.onTap,
  });

  final Promotion promotion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _getPromotionColors(promotion.type);
    final icon = _getPromotionIcon(promotion.type);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    promotion.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (promotion.discountText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  promotion.discountText,
                  style: TextStyle(
                    color: colors.first,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get gradient colors based on promotion type
  List<Color> _getPromotionColors(PromotionType type) {
    switch (type) {
      case PromotionType.percentage:
        return [AppColors.persianIndigo, AppColors.mauve];
      case PromotionType.fixedAmount:
        return [AppColors.russianViolet, AppColors.indigo];
      case PromotionType.buyOneGetOne:
        return [AppColors.success, const Color(0xFF4CAF50)];
      case PromotionType.freeDelivery:
        return [const Color(0xFF2196F3), const Color(0xFF03DAC6)];
      case PromotionType.bundle:
        return [const Color(0xFFFF9800), const Color(0xFFFFC107)];
      case PromotionType.seasonal:
        return [const Color(0xFFE91E63), const Color(0xFF9C27B0)];
    }
  }

  /// Get icon based on promotion type
  IconData _getPromotionIcon(PromotionType type) {
    switch (type) {
      case PromotionType.percentage:
        return Icons.percent;
      case PromotionType.fixedAmount:
        return Icons.attach_money;
      case PromotionType.buyOneGetOne:
        return Icons.add_box;
      case PromotionType.freeDelivery:
        return Icons.local_shipping;
      case PromotionType.bundle:
        return Icons.inventory;
      case PromotionType.seasonal:
        return Icons.celebration;
    }
  }
}