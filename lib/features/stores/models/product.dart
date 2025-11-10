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
      return difference.inDays == 1
          ? 'hace 1 día'
          : 'hace ${difference.inDays} días';
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

  // Discount/offer related fields
  final double? discountPrice;
  final DateTime? discountEndDate;
  final bool hasActiveOffer;
  final double effectivePrice;
  final int? storeId;
  final int? categoryId;

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
    this.discountPrice,
    this.discountEndDate,
    this.hasActiveOffer = false,
    double? effectivePrice,
    this.storeId,
    this.categoryId,
  }) : seller =
           seller ??
           const ProductSeller(
             id: 'default',
             name: 'Vendedor',
             avatar: '',
             rating: 4.0,
             reviewCount: 10,
           ),
       effectivePrice = effectivePrice ?? price;

  /// Formatted price string
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Formatted effective price (considering discounts)
  String get formattedEffectivePrice =>
      '\$${effectivePrice.toStringAsFixed(2)}';

  /// Formatted discount price
  String get formattedDiscountPrice => discountPrice != null
      ? '\$${discountPrice!.toStringAsFixed(2)}'
      : formattedPrice;

  /// Check if product has a valid active discount
  bool get hasValidDiscount {
    if (!hasActiveOffer || discountPrice == null || discountEndDate == null) {
      return false;
    }
    return DateTime.now().isBefore(discountEndDate!);
  }

  /// Calculate discount percentage
  double get discountPercentage {
    if (!hasValidDiscount || discountPrice == null) return 0.0;
    return ((price - discountPrice!) / price * 100);
  }

  /// Formatted discount percentage
  String get formattedDiscountPercentage {
    if (!hasValidDiscount) return '';
    return '-${discountPercentage.toStringAsFixed(0)}%';
  }

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

    return breakdown.map(
      (key, value) => MapEntry(key, value / reviews.length * 100),
    );
  }

  /// Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse discount end date if available
    DateTime? discountEndDate;
    if (json['discount_end_date'] != null) {
      try {
        discountEndDate = DateTime.parse(json['discount_end_date']);
      } catch (e) {
        discountEndDate = null;
      }
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['long_description'] ??
          json['description'] ??
          json['short_description'] ??
          '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: _getFirstImage(json),
      additionalImages: _getAdditionalImages(json),
      category: json['category'] ?? '',
      isAvailable: json['is_active'] ?? json['isAvailable'] ?? true,
      stock: json['stock'] ?? 0,
      tags: _parseTags(json['tags']),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      reviews: [], // Reviews are loaded separately
      seller: json['seller'] != null
          ? ProductSeller(
              id: json['seller']['id']?.toString() ?? '',
              name: json['seller']['name'] ?? 'Vendedor',
              avatar: json['seller']['avatar'] ?? '',
              rating: (json['seller']['rating'] ?? 4.0).toDouble(),
              reviewCount: json['seller']['review_count'] ??
                  json['seller']['reviewCount'] ??
                  0,
            )
          : null,
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      discountEndDate: discountEndDate,
      hasActiveOffer: json['has_active_offer'] ?? false,
      effectivePrice: json['effective_price'] != null
          ? (json['effective_price'] as num).toDouble()
          : null,
      storeId: json['store_id'],
      categoryId: json['category_id'],
    );
  }

  /// Extract first image from various possible JSON structures
  static String _getFirstImage(Map<String, dynamic> json) {
    // Check for images array
    if (json['images'] != null && json['images'] is List) {
      final images = json['images'] as List;
      
      if (images.isEmpty) {
      } else {
        // If images is an array of strings (URLs)
        if (images.first is String) {
          final imageUrl = (images.first as String).trim();
          if (imageUrl.isNotEmpty) {
            return imageUrl;
          }
        }
        
        // If images is an array of objects with url property
        else if (images.first is Map) {
          final firstImg = images.first as Map;
          
          if (firstImg['url'] != null) {
            final imageUrl = firstImg['url'].toString().trim();
            if (imageUrl.isNotEmpty) {
              return imageUrl;
            }
          }
          
          // Try other common field names
          if (firstImg['image_url'] != null) {
            final imageUrl = firstImg['image_url'].toString().trim();
            if (imageUrl.isNotEmpty) {
              return imageUrl;
            }
          }
        }
      }
    }

    // Fallback to single image_url field
    final fallback = (json['image_url'] ?? json['imageUrl'] ?? '').toString().trim();
    return fallback;
  }

  /// Extract additional images from JSON
  static List<String> _getAdditionalImages(Map<String, dynamic> json) {
    
    if (json['images'] != null && json['images'] is List) {
      final images = json['images'] as List;
      
      // Get all images except the first one
      final additionalImages = images
          .skip(1)
          .map<String>((img) {
            // If img is a string URL
            if (img is String) {
              return img.trim();
            }
            // If img is an object with url property
            if (img is Map && img['url'] != null) {
              return img['url'].toString().trim();
            }
            // Try image_url field
            if (img is Map && img['image_url'] != null) {
              return img['image_url'].toString().trim();
            }
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
      
      return additionalImages;
    }

    // Fallback to additional_images field
    if (json['additional_images'] != null ||
        json['additionalImages'] != null) {
      final additionalImgs = json['additional_images'] ?? json['additionalImages'];
      if (additionalImgs is List) {
        final result = additionalImgs
            .map<String>((img) => img.toString().trim())
            .where((url) => url.isNotEmpty)
            .toList();
        return result;
      }
    }

    return [];
  }

  /// Parse tags from JSON (can be array of strings or objects)
  static List<String> _parseTags(dynamic tagsData) {
    if (tagsData == null) return [];

    if (tagsData is List) {
      return tagsData
          .map<String>((tag) {
            if (tag is String) {
              return tag;
            } else if (tag is Map && tag['name'] != null) {
              return tag['name'].toString();
            }
            return '';
          })
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'additional_images': additionalImages,
      'category': category,
      'is_available': isAvailable,
      'stock': stock,
      'tags': tags,
      'rating': rating,
      'review_count': reviewCount,
      'discount_price': discountPrice,
      'discount_end_date': discountEndDate?.toIso8601String(),
      'has_active_offer': hasActiveOffer,
      'effective_price': effectivePrice,
      'store_id': storeId,
      'category_id': categoryId,
    };
  }
}
