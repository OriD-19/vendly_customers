import 'package:equatable/equatable.dart';

/// Base class for all cart events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}
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

class RemoveFromCart extends CartEvent {
  const RemoveFromCart(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class IncrementItemQuantity extends CartEvent {
  const IncrementItemQuantity(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];
}

class DecrementItemQuantity extends CartEvent {
  const DecrementItemQuantity(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];
}
