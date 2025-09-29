/// Product model for store catalog
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final int stock;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.stock = 0,
    this.tags = const [],
  });

  /// Formatted price string
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Check if product is in stock
  bool get inStock => stock > 0;
}
