/// Promotion model for store offers and deals
class Promotion {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final PromotionType type;
  final double? discountPercentage;
  final double? discountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> applicableProductIds;
  final String? promoCode;
  final bool isActive;

  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    this.discountPercentage,
    this.discountAmount,
    required this.startDate,
    required this.endDate,
    this.applicableProductIds = const [],
    this.promoCode,
    this.isActive = true,
  });

  /// Get formatted discount text
  String get discountText {
    if (discountPercentage != null) {
      return '${discountPercentage!.toInt()}% OFF';
    } else if (discountAmount != null) {
      return '\$${discountAmount!.toStringAsFixed(2)} OFF';
    }
    return 'Oferta Especial';
  }

  /// Check if promotion is currently active
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}

/// Types of promotions
enum PromotionType {
  percentage,
  fixedAmount,
  buyOneGetOne,
  freeDelivery,
  bundle,
  seasonal,
}

/// Product category for better organization
class ProductCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int productCount;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.productCount,
  });
}
