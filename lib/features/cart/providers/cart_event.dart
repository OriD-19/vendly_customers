import 'package:equatable/equatable.dart';

/// Base class for all cart events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Event to add an item to the cart
class AddToCart extends CartEvent {
  const AddToCart({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.size,
    this.quantity = 1,
  });

  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final String? size;
  final int quantity;

  @override
  List<Object?> get props => [productId, name, price, imageUrl, size, quantity];
}

/// Event to update item quantity in cart
class UpdateCartItemQuantity extends CartEvent {
  const UpdateCartItemQuantity({
    required this.itemId,
    required this.quantity,
  });

  final String itemId;
  final int quantity;

  @override
  List<Object> get props => [itemId, quantity];
}

/// Event to remove an item from the cart
class RemoveFromCart extends CartEvent {
  const RemoveFromCart(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];
}

/// Event to clear all items from cart
class ClearCart extends CartEvent {
  const ClearCart();
}

/// Event to load cart from storage
class LoadCart extends CartEvent {
  const LoadCart();
}

/// Event to increment item quantity
class IncrementItemQuantity extends CartEvent {
  const IncrementItemQuantity(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];
}

/// Event to decrement item quantity
class DecrementItemQuantity extends CartEvent {
  const DecrementItemQuantity(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];
}
