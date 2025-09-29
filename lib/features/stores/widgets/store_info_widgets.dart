import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Store rating widget with stars and review count
class StoreRating extends StatelessWidget {
  const StoreRating({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.size = 16,
    this.showReviewCount = true,
  });

  final double rating;
  final int reviewCount;
  final double size;
  final bool showReviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star rating
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < rating.floor()
                  ? Icons.star
                  : index < rating
                      ? Icons.star_half
                      : Icons.star_border,
              color: Colors.amber,
              size: size,
            );
          }),
        ),
        
        const SizedBox(width: 4),
        
        // Rating number
        Text(
          rating.toStringAsFixed(1),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Review count (optional)
        if (showReviewCount) ...[
          const SizedBox(width: 4),
          Text(
            '(${_formatReviewCount(reviewCount)})',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

/// Store category badge widget
class StoreCategoryBadge extends StatelessWidget {
  const StoreCategoryBadge({
    super.key,
    required this.category,
    this.isVerified = false,
  });

  final String category;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.mauve.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.mauve.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            category,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.persianIndigo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        if (isVerified) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ],
    );
  }
}

/// Store status indicator (open/closed)
class StoreStatusIndicator extends StatelessWidget {
  const StoreStatusIndicator({
    super.key,
    required this.isOpen,
    required this.deliveryInfo,
  });

  final bool isOpen;
  final String deliveryInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOpen ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        
        const SizedBox(width: 4),
        
        // Status text
        Text(
          isOpen ? 'Abierto' : 'Cerrado',
          style: AppTypography.labelSmall.copyWith(
            color: isOpen ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Delivery info
        Expanded(
          child: Text(
            deliveryInfo,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}