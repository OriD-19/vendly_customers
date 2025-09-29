import 'cart_item.dart';

/// Cart model managing collection of cart items and order calculations
class Cart {
  const Cart({
    required this.items,
    this.shippingCost = 5.00,
    this.taxRate = 0.08, // 8% tax rate
  });

  final List<CartItem> items;
  final double shippingCost;
  final double taxRate;

  /// Calculate subtotal (sum of all item totals)
  double get subtotal {
    return items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  /// Calculate tax amount based on subtotal
  double get taxAmount {
    return subtotal * taxRate;
  }

  /// Calculate total including shipping and tax
  double get total {
    return subtotal + shippingCost + taxAmount;
  }

  /// Get total number of items in cart
  int get itemCount {
    return items.fold(0, (count, item) => count + item.quantity);
  }

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Create a copy of cart with updated items
  Cart copyWith({
    List<CartItem>? items,
    double? shippingCost,
    double? taxRate,
  }) {
    return Cart(
      items: items ?? this.items,
      shippingCost: shippingCost ?? this.shippingCost,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  /// Add item to cart or update quantity if item already exists
  Cart addItem(CartItem newItem) {
    final existingIndex = items.indexWhere((item) => 
        item.productId == newItem.productId && 
        item.size == newItem.size && 
        item.color == newItem.color);

    if (existingIndex >= 0) {
      // Update existing item quantity
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + newItem.quantity,
      );
      return copyWith(items: updatedItems);
    } else {
      // Add new item
      return copyWith(items: [...items, newItem]);
    }
  }

  /// Update item quantity
  Cart updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      return removeItem(itemId);
    }

    final updatedItems = items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems);
  }

  /// Remove item from cart
  Cart removeItem(String itemId) {
    final updatedItems = items.where((item) => item.id != itemId).toList();
    return copyWith(items: updatedItems);
  }

  /// Clear all items from cart
  Cart clear() {
    return copyWith(items: []);
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'shippingCost': shippingCost,
      'taxRate': taxRate,
    };
  }

  /// Create from map for deserialization
  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      shippingCost: (map['shippingCost'] ?? 5.00).toDouble(),
      taxRate: (map['taxRate'] ?? 0.08).toDouble(),
    );
  }

  /// Create empty cart
  static Cart empty() => const Cart(items: []);
}