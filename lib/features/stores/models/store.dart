import 'product.dart';

/// Store model with comprehensive information
class Store {
  final String id;
  final String name;
  final String description;
  final String category;
  final String logoUrl;
  final String bannerUrl;
  final double rating;
  final int reviewCount;
  final String address;
  final String phone;
  final String email;
  final StoreHours hours;
  final List<Product> featuredProducts;
  final List<String> tags;
  final bool isOpen;
  final bool isVerified;
  final double deliveryFee;
  final int estimatedDeliveryTime; // in minutes
  final List<String> showcaseImages; // NEW: Image carousel URLs from API
  final int? ownerId; // NEW: Owner ID from API
  final DateTime? createdAt; // NEW: Creation timestamp from API
  final DateTime? updatedAt; // NEW: Update timestamp from API
  final String? storeLocation; // NEW: Location from API
  final String? type; // NEW: Store type from API

  const Store({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.logoUrl,
    required this.bannerUrl,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.phone,
    required this.email,
    required this.hours,
    required this.featuredProducts,
    this.tags = const [],
    this.isOpen = true,
    this.isVerified = false,
    this.deliveryFee = 0.0,
    this.estimatedDeliveryTime = 30,
    this.showcaseImages = const [],
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    this.storeLocation,
    this.type,
  });

  /// Create Store from API JSON response
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['name'] ?? 'Tienda sin nombre',
      description: json['description'] ?? 'Sin descripción',
      category: json['type'] ?? 'General',
      logoUrl: json['profile_image'] ?? '',
      bannerUrl: (json['showcase_images'] as List<dynamic>?)?.isNotEmpty == true
          ? json['showcase_images'][0]
          : '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      reviewCount: json['review_count'] ?? 0,
      address: json['store_location'] ?? 'Dirección no disponible',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      hours: const StoreHours(
        monday: '9:00 AM - 6:00 PM',
        tuesday: '9:00 AM - 6:00 PM',
        wednesday: '9:00 AM - 6:00 PM',
        thursday: '9:00 AM - 6:00 PM',
        friday: '9:00 AM - 6:00 PM',
        saturday: '10:00 AM - 4:00 PM',
        sunday: 'Cerrado',
      ),
      featuredProducts: const [],
      tags: _extractTags(json),
      isOpen: json['is_open'] ?? true,
      isVerified: json['is_verified'] ?? false,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      estimatedDeliveryTime: json['estimated_delivery_time'] ?? 30,
      showcaseImages: (json['showcase_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ownerId: json['owner_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      storeLocation: json['store_location'],
      type: json['type'],
    );
  }

  /// Convert Store to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type ?? category,
      'profile_image': logoUrl,
      'showcase_images': showcaseImages,
      'rating': rating,
      'review_count': reviewCount,
      'store_location': storeLocation ?? address,
      'phone': phone,
      'email': email,
      'is_open': isOpen,
      'is_verified': isVerified,
      'delivery_fee': deliveryFee,
      'estimated_delivery_time': estimatedDeliveryTime,
      'owner_id': ownerId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Extract tags from JSON (helper method)
  static List<String> _extractTags(Map<String, dynamic> json) {
    final tags = <String>[];
    
    // Add category/type as tag
    if (json['type'] != null) tags.add(json['type']);
    
    // Add delivery option tag
    final deliveryFee = (json['delivery_fee'] as num?)?.toDouble() ?? 0.0;
    if (deliveryFee == 0.0) tags.add('Envío gratis');
    
    // Add verified tag
    if (json['is_verified'] == true) tags.add('Verificado');
    
    return tags;
  }

  /// Get formatted rating string
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get review count text
  String get reviewText =>
      reviewCount == 1 ? '1 reseña' : '$reviewCount reseñas';

  /// Get delivery info text
  String get deliveryInfo => deliveryFee == 0
      ? 'Envío gratis • $estimatedDeliveryTime min'
      : '\$${deliveryFee.toStringAsFixed(2)} • $estimatedDeliveryTime min';

  /// Get up to 3 featured products for carousel
  List<Product> get carouselProducts => featuredProducts.take(3).toList();

  /// Get showcase images for carousel (use showcase images or fallback to banner)
  List<String> get carouselImages {
    if (showcaseImages.isNotEmpty) {
      return showcaseImages;
    }
    // Fallback to banner if no showcase images
    return bannerUrl.isNotEmpty ? [bannerUrl] : [];
  }

  /// Create a copy of Store with updated fields
  Store copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? logoUrl,
    String? bannerUrl,
    double? rating,
    int? reviewCount,
    String? address,
    String? phone,
    String? email,
    StoreHours? hours,
    List<Product>? featuredProducts,
    List<String>? tags,
    bool? isOpen,
    bool? isVerified,
    double? deliveryFee,
    int? estimatedDeliveryTime,
    List<String>? showcaseImages,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? storeLocation,
    String? type,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hours: hours ?? this.hours,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      tags: tags ?? this.tags,
      isOpen: isOpen ?? this.isOpen,
      isVerified: isVerified ?? this.isVerified,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      showcaseImages: showcaseImages ?? this.showcaseImages,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storeLocation: storeLocation ?? this.storeLocation,
      type: type ?? this.type,
    );
  }
}

/// Store operating hours
class StoreHours {
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  final String sunday;

  const StoreHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  /// Get current day hours (simplified for prototype)
  String get today => '8:00 AM - 10:00 PM'; // Simplified for demo
}
