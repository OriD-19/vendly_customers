/// Cart item model representing a product in the shopping cart
class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.size,
    this.color,
  });

  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final String? size;
  final String? color;

  /// Calculate total price for this cart item (price * quantity)
  double get totalPrice => price * quantity;

  /// Create a copy of this cart item with updated values
  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? size,
    String? color,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'size': size,
      'color': color,
    };
  }

  /// Create from map for deserialization
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
      size: map['size'],
      color: map['color'],
    );
  }

  /// JSON serialization (alias for toMap)
  Map<String, dynamic> toJson() => toMap();

  /// JSON deserialization (alias for fromMap)
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem.fromMap(json);
}