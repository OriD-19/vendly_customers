import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../models/cart.dart';

/// Cart state that holds the current cart data
class CartState extends Equatable {
  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  /// Get the current cart object
  Cart get cart => Cart(items: items);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Get total number of items in cart
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get subtotal amount
  double get subtotal => cart.subtotal;

  /// Get total amount
  double get total => cart.total;

  /// Copy state with new values
  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Clear error
  CartState clearError() {
    return copyWith(error: '');
  }

  @override
  List<Object?> get props => [items, isLoading, error];
}
