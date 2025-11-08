/// Category model for product categories
class Category {
  final int id;
  final String name;
  final String? description;
  final int productCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.productCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Category from API JSON response
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      productCount: json['product_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'product_count': productCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get icon for category based on name
  /// This can be customized based on category names
  String getIconName() {
    final lowerName = name.toLowerCase();
    
    if (lowerName.contains('comida') || lowerName.contains('food') || lowerName.contains('restaurant')) {
      return 'restaurant';
    } else if (lowerName.contains('market') || lowerName.contains('grocery') || lowerName.contains('supermercado')) {
      return 'local_grocery_store';
    } else if (lowerName.contains('farmacia') || lowerName.contains('pharmacy') || lowerName.contains('medicina')) {
      return 'local_pharmacy';
    } else if (lowerName.contains('ropa') || lowerName.contains('clothing') || lowerName.contains('fashion')) {
      return 'checkroom';
    } else if (lowerName.contains('tecnología') || lowerName.contains('technology') || lowerName.contains('electrónica')) {
      return 'devices';
    } else if (lowerName.contains('deportes') || lowerName.contains('sports')) {
      return 'sports_soccer';
    } else if (lowerName.contains('hogar') || lowerName.contains('home')) {
      return 'home';
    } else if (lowerName.contains('bebidas') || lowerName.contains('drinks')) {
      return 'local_bar';
    } else {
      return 'category';
    }
  }
}
