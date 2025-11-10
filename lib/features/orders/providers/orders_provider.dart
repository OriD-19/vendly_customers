import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/orders_service.dart';

/// State class for orders screen
class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final bool isCancelingOrder;
  final int? cancelingOrderId;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.isCancelingOrder = false,
    this.cancelingOrderId,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    bool? isCancelingOrder,
    int? cancelingOrderId,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCancelingOrder: isCancelingOrder ?? this.isCancelingOrder,
      cancelingOrderId: cancelingOrderId,
    );
  }

  OrdersState clearError() {
    return copyWith(error: '');
  }

  OrdersState clearCancelingState() {
    return copyWith(
      isCancelingOrder: false,
      cancelingOrderId: null,
    );
  }

  /// Get active orders (pending, confirmed, processing, shipped)
  List<Order> get activeOrders {
    return orders.where((order) => order.isActive).toList();
  }

  /// Get completed/canceled orders
  List<Order> get completedOrders {
    return orders.where((order) => order.isCompleted || order.isCanceled).toList();
  }
}

/// Notifier class for orders functionality
class OrdersNotifier extends StateNotifier<OrdersState> {
  OrdersNotifier() : super(const OrdersState()) {
    loadOrders();
  }

  final OrdersService _ordersService = OrdersService();

  /// Load all orders for the current user
  Future<void> loadOrders() async {
    state = state.copyWith(
      isLoading: true,
      error: '',
    );

    try {
      final result = await _ordersService.getOrders();

      if (result.isSuccess) {
        state = state.copyWith(
          orders: result.orders ?? [],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: result.error ?? 'Error al cargar los pedidos',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error al cargar los pedidos: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Cancel an order by ID
  Future<bool> cancelOrder(int orderId) async {
    state = state.copyWith(
      isCancelingOrder: true,
      cancelingOrderId: orderId,
    );

    try {
      final result = await _ordersService.cancelOrder(orderId);

      if (result.isSuccess) {
        // Reload orders to get updated data
        await loadOrders();
        state = state.clearCancelingState();
        return true;
      } else {
        state = state.copyWith(
          error: result.error ?? 'Error al cancelar el pedido',
          isCancelingOrder: false,
          cancelingOrderId: null,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error al cancelar el pedido: ${e.toString()}',
        isCancelingOrder: false,
        cancelingOrderId: null,
      );
      return false;
    }
  }

  /// Check if a specific order is being canceled
  bool isOrderCanceling(int orderId) {
    return state.isCancelingOrder && state.cancelingOrderId == orderId;
  }

  /// Retry loading orders after an error
  void retry() {
    loadOrders();
  }

  /// Refresh orders (for pull-to-refresh)
  Future<void> refresh() async {
    await loadOrders();
  }
}

/// Provider for orders functionality
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>(
  (ref) => OrdersNotifier(),
);
