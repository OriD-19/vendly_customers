import 'package:dio/dio.dart';
import '../../../core/services/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/order.dart';

/// Service for managing orders
class OrdersService {
  final Dio _dio = ApiConfig.dio;

  /// Fetch all orders for the current customer
  Future<OrdersResult> getOrders() async {
    try {
      // Get current user ID
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        return OrdersResult.error('Usuario no autenticado');
      }

      final response = await _dio.get('/orders/customer/${user.id}');

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = response.data as List<dynamic>;
        final orders = ordersJson
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by created date (newest first)
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return OrdersResult.success(orders);
      } else {
        return OrdersResult.error('Error al cargar los pedidos');
      }
    } on DioException catch (e) {
      return OrdersResult.error(_handleDioError(e));
    } catch (e) {
      return OrdersResult.error('Error inesperado al cargar los pedidos');
    }
  }

  /// Fetch a specific order by ID
  Future<OrderResult> getOrder(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final order = Order.fromJson(response.data as Map<String, dynamic>);
        return OrderResult.success(order);
      } else {
        return OrderResult.error('Error al cargar el pedido');
      }
    } on DioException catch (e) {
      return OrderResult.error(_handleDioError(e));
    } catch (e) {
      return OrderResult.error('Error inesperado al cargar el pedido');
    }
  }

  /// Cancel an order
  Future<OrderResult> cancelOrder(int orderId) async {
    try {
      final response = await _dio.post('/orders/$orderId/cancel');

      if (response.statusCode == 200) {
        final order = Order.fromJson(response.data as Map<String, dynamic>);
        return OrderResult.success(order);
      } else {
        return OrderResult.error('Error al cancelar el pedido');
      }
    } on DioException catch (e) {
      return OrderResult.error(_handleDioError(e));
    } catch (e) {
      return OrderResult.error('Error inesperado al cancelar el pedido');
    }
  }

  /// Handle Dio errors and return user-friendly messages in Spanish
  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado. Verifica tu conexión a internet.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
    }

    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'Solicitud inválida';
        case 401:
          return 'Sesión expirada. Por favor inicia sesión nuevamente.';
        case 403:
          return 'No tienes permiso para realizar esta acción';
        case 404:
          return 'Pedido no encontrado';
        case 500:
          return 'Error del servidor. Intenta de nuevo más tarde.';
        default:
          return 'Error al procesar la solicitud';
      }
    }

    return 'Error de conexión. Verifica tu internet.';
  }
}

/// Result wrapper for multiple orders
class OrdersResult {
  final List<Order>? orders;
  final String? error;

  OrdersResult.success(this.orders) : error = null;
  OrdersResult.error(this.error) : orders = null;

  bool get isSuccess => orders != null;
  bool get isError => error != null;
}

/// Result wrapper for single order
class OrderResult {
  final Order? order;
  final String? error;

  OrderResult.success(this.order) : error = null;
  OrderResult.error(this.error) : order = null;

  bool get isSuccess => order != null;
  bool get isError => error != null;
}
