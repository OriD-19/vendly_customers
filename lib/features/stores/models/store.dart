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
  });

  /// Get formatted rating string
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get review count text
  String get reviewText => reviewCount == 1 ? '1 reseña' : '$reviewCount reseñas';

  /// Get delivery info text
  String get deliveryInfo => deliveryFee == 0 
      ? 'Envío gratis • $estimatedDeliveryTime min' 
      : '\$${deliveryFee.toStringAsFixed(2)} • $estimatedDeliveryTime min';

  /// Get up to 3 featured products for carousel
  List<Product> get carouselProducts => 
      featuredProducts.take(3).toList();
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