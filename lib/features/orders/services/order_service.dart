import 'package:dio/dio.dart';
import '../../../core/services/api_config.dart';
import '../models/order_request.dart';

/// Service for order operations
class OrderService {
  /// Create a new order
  static Future<OrderResult> createOrder(CreateOrderRequest request) async {
    try {
      final response = await ApiConfig.dio.post(
        '/orders/',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final orderData = response.data;
        final order = OrderResponse.fromJson(orderData);
        
        return OrderResult(
          success: true,
          order: order,
        );
      }

      return OrderResult(
        success: false,
        error: 'Error al crear el pedido',
      );
    } on DioException catch (e) {
      return OrderResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return OrderResult(
        success: false,
        error: 'Error inesperado al crear el pedido',
      );
    }
  }

  /// Handle Dio errors and return user-friendly messages
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Verifica tu conexión.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          // Try to extract validation errors
          final data = error.response?.data;
          if (data is Map && data.containsKey('detail')) {
            return data['detail'].toString();
          }
          return 'Datos inválidos. Verifica la información del pedido.';
        } else if (statusCode == 401) {
          return 'Sesión expirada. Inicia sesión nuevamente.';
        } else if (statusCode == 404) {
          return 'Producto no encontrado.';
        } else if (statusCode == 500) {
          return 'Error del servidor. Intenta más tarde.';
        }
        return 'Error al procesar el pedido (código: $statusCode)';
      
      case DioExceptionType.cancel:
        return 'Operación cancelada';
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'Sin conexión a internet';
        }
        return 'Error de conexión. Verifica tu red.';
      
      default:
        return 'Error al crear el pedido';
    }
  }
}

/// Result wrapper for order operations
class OrderResult {
  const OrderResult({
    required this.success,
    this.order,
    this.error,
  });

  final bool success;
  final OrderResponse? order;
  final String? error;
}
