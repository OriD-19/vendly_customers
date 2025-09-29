/// Product review model
class ProductReview {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;

  const ProductReview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  /// Formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'hace 1 mes' : 'hace $months meses';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'hace 1 semana' : 'hace $weeks semanas';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'hace 1 día' : 'hace ${difference.inDays} días';
    } else {
      return 'hoy';
    }
  }
}

/// Product seller information
class ProductSeller {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int reviewCount;

  const ProductSeller({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.reviewCount,
  });

  /// Formatted rating string
  String get formattedRating => '$rating (${reviewCount}+ opiniones)';
}

/// Product model for store catalog
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> additionalImages;
  final String category;
  final bool isAvailable;
  final int stock;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final List<ProductReview> reviews;
  final ProductSeller seller;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.additionalImages = const [],
    required this.category,
    this.isAvailable = true,
    this.stock = 0,
    this.tags = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.reviews = const [],
    ProductSeller? seller,
  }) : seller = seller ?? const ProductSeller(
    id: 'default',
    name: 'Vendedor',
    avatar: '',
    rating: 4.0,
    reviewCount: 10,
  );

  /// Formatted price string
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Check if product is in stock
  bool get inStock => stock > 0;

  /// All product images (main + additional)
  List<String> get allImages => [imageUrl, ...additionalImages];

  /// Rating breakdown for reviews
  Map<int, double> get ratingBreakdown {
    if (reviews.isEmpty) return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    
    final breakdown = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    
    for (final review in reviews) {
      final rating = review.rating.round();
      breakdown[rating] = (breakdown[rating] ?? 0) + 1;
    }
    
    return breakdown.map((key, value) => 
      MapEntry(key, value / reviews.length * 100));
  }
}
