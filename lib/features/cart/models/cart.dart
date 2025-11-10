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

  double get subtotal {
    return items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  double get taxAmount {
    return subtotal * taxRate;
  }

  double get total {
    return subtotal + shippingCost + taxAmount;
  }

  int get itemCount {
    return items.fold(0, (count, item) => count + item.quantity);
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

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

  Cart addItem(CartItem newItem) {
    final existingIndex = items.indexWhere((item) => 
        item.productId == newItem.productId && 
        item.size == newItem.size && 
        item.color == newItem.color);

    if (existingIndex >= 0) {
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

  Cart removeItem(String itemId) {
    final updatedItems = items.where((item) => item.id != itemId).toList();
    return copyWith(items: updatedItems);
  }

  Cart clear() {
    return copyWith(items: []);
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'shippingCost': shippingCost,
      'taxRate': taxRate,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      shippingCost: (map['shippingCost'] ?? 5.00).toDouble(),
      taxRate: (map['taxRate'] ?? 0.08).toDouble(),
    );
  }

  static Cart empty() => const Cart(items: []);
}