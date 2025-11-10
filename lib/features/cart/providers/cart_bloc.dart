import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../models/cart_item.dart';

/// BLoC for managing shopping cart state
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<LoadCart>(_onLoadCart);
    on<IncrementItemQuantity>(_onIncrementItemQuantity);
    on<DecrementItemQuantity>(_onDecrementItemQuantity);
  }

  static const String _cartStorageKey = 'shopping_cart';
  final _uuid = const Uuid();

  /// Add item to cart
  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      final currentItems = List<CartItem>.from(state.items);
      
      // Check if item already exists in cart (same product and size)
      final existingIndex = currentItems.indexWhere(
        (item) => item.productId == event.productId && item.size == event.size,
      );

      if (existingIndex != -1) {
        // Update quantity of existing item
        final existingItem = currentItems[existingIndex];
        currentItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + event.quantity,
        );
      } else {
        // Add new item
        final newItem = CartItem(
          id: _uuid.v4(),
          productId: event.productId,
          name: event.name,
          price: event.price,
          quantity: event.quantity,
          size: event.size,
          imageUrl: event.imageUrl,
        );
        currentItems.add(newItem);
      }

      emit(state.copyWith(items: currentItems));
      await _saveCart(currentItems);
    } catch (e) {
      emit(state.copyWith(error: 'Error al agregar producto al carrito'));
    }
  }

  /// Update item quantity
  Future<void> _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      final currentItems = List<CartItem>.from(state.items);
      final index = currentItems.indexWhere((item) => item.id == event.itemId);

      if (index != -1) {
        if (event.quantity <= 0) {
          // Remove item if quantity is 0 or less
          currentItems.removeAt(index);
        } else {
          // Update quantity
          currentItems[index] = currentItems[index].copyWith(
            quantity: event.quantity,
          );
        }

        emit(state.copyWith(items: currentItems));
        await _saveCart(currentItems);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar cantidad'));
    }
  }

  /// Increment item quantity
  Future<void> _onIncrementItemQuantity(
    IncrementItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      final currentItems = List<CartItem>.from(state.items);
      final index = currentItems.indexWhere((item) => item.id == event.itemId);

      if (index != -1) {
        currentItems[index] = currentItems[index].copyWith(
          quantity: currentItems[index].quantity + 1,
        );

        emit(state.copyWith(items: currentItems));
        await _saveCart(currentItems);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al incrementar cantidad'));
    }
  }

  /// Decrement item quantity
  Future<void> _onDecrementItemQuantity(
    DecrementItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      final currentItems = List<CartItem>.from(state.items);
      final index = currentItems.indexWhere((item) => item.id == event.itemId);

      if (index != -1) {
        final newQuantity = currentItems[index].quantity - 1;
        
        if (newQuantity <= 0) {
          // Remove item if quantity reaches 0
          currentItems.removeAt(index);
        } else {
          currentItems[index] = currentItems[index].copyWith(
            quantity: newQuantity,
          );
        }

        emit(state.copyWith(items: currentItems));
        await _saveCart(currentItems);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al decrementar cantidad'));
    }
  }

  /// Remove item from cart
  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      final currentItems = List<CartItem>.from(state.items);
      currentItems.removeWhere((item) => item.id == event.itemId);

      emit(state.copyWith(items: currentItems));
      await _saveCart(currentItems);
    } catch (e) {
      emit(state.copyWith(error: 'Error al eliminar producto'));
    }
  }

  /// Clear all items from cart
  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      emit(state.copyWith(items: []));
      await _saveCart([]);
    } catch (e) {
      emit(state.copyWith(error: 'Error al vaciar carrito'));
    }
  }

  /// Load cart from storage
  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartStorageKey);

      if (cartJson != null) {
        final List<dynamic> itemsJson = json.decode(cartJson);
        final items = itemsJson
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
        
        emit(state.copyWith(items: items, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar carrito',
      ));
    }
  }

  /// Save cart to storage
  Future<void> _saveCart(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = items.map((item) => item.toJson()).toList();
      await prefs.setString(_cartStorageKey, json.encode(itemsJson));
    } catch (e) {
      // Log error but don't throw - cart still works in memory
      print('Error saving cart to storage: $e');
    }
  }
}
