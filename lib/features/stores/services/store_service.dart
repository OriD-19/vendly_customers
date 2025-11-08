import 'package:dio/dio.dart';
import '../../../core/services/api_config.dart';
import '../models/store.dart';

/// Service for fetching stores from the API
class StoreService {
  static int calculateSkip(int page, int limit) {
    return (page - 1) * limit;
  }

  /// Fetch all stores with optional pagination
  /// Uses skip-limit pagination mechanism
  static Future<StoreResult> getAllStores({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        ApiConfig.stores,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle both single object and array responses
        List<dynamic> storesJson;
        if (data is List) {
          storesJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          storesJson = data['items'] as List<dynamic>;
        } else {
          return StoreResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            stores: [],
          );
        }

        final stores = storesJson
            .map((json) => Store.fromJson(json as Map<String, dynamic>))
            .toList();

        return StoreResult(
          success: true,
          stores: stores,
          total: data is Map ? data['total'] : stores.length,
        );
      } else {
        return StoreResult(
          success: false,
          error: 'Error al cargar tiendas. Código: ${response.statusCode}',
          stores: [],
        );
      }
    } on DioException catch (e) {
      return StoreResult(
        success: false,
        error: _handleDioError(e),
        stores: [],
      );
    } catch (e) {
      return StoreResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        stores: [],
      );
    }
  }

  /// Fetch a specific store by ID
  static Future<StoreDetailResult> getStoreById(int id) async {
    try {
      final response = await ApiConfig.dio.get(ApiConfig.storeById(id));

      if (response.statusCode == 200) {
        final store = Store.fromJson(response.data as Map<String, dynamic>);
        return StoreDetailResult(
          success: true,
          store: store,
        );
      } else {
        return StoreDetailResult(
          success: false,
          error: 'Error al cargar la tienda. Código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return StoreDetailResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return StoreDetailResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Search stores by name or category
  /// Uses skip-limit pagination mechanism
  static Future<StoreResult> searchStores({
    required String query,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        '${ApiConfig.stores}/search',
        queryParameters: {
          'q': query,
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        List<dynamic> storesJson;
        if (data is List) {
          storesJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          storesJson = data['items'] as List<dynamic>;
        } else {
          return StoreResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            stores: [],
          );
        }

        final stores = storesJson
            .map((json) => Store.fromJson(json as Map<String, dynamic>))
            .toList();

        return StoreResult(
          success: true,
          stores: stores,
          total: data is Map ? data['total'] : stores.length,
        );
      } else {
        return StoreResult(
          success: false,
          error: 'Error en la búsqueda. Código: ${response.statusCode}',
          stores: [],
        );
      }
    } on DioException catch (e) {
      return StoreResult(
        success: false,
        error: _handleDioError(e),
        stores: [],
      );
    } catch (e) {
      return StoreResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        stores: [],
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
        final data = error.response?.data;

        if (statusCode == 404) {
          return 'Tienda no encontrada';
        } else if (statusCode == 500) {
          return 'Error del servidor. Intenta más tarde.';
        }
        
        if (data is Map<String, dynamic>) {
          return data['detail'] ?? data['error'] ?? 'Error al cargar tiendas';
        }
        
        return 'Error de conexión (${statusCode ?? 'desconocido'})';

      case DioExceptionType.cancel:
        return 'Solicitud cancelada';

      case DioExceptionType.badCertificate:
        return 'Error de certificado de seguridad';

      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor. Verifica tu conexión.';

      case DioExceptionType.unknown:
        return 'Error de conexión. Intenta nuevamente.';
    }
  }
}

/// Result class for store list operations
class StoreResult {
  final bool success;
  final List<Store> stores;
  final String? error;
  final int? total;

  StoreResult({
    required this.success,
    required this.stores,
    this.error,
    this.total,
  });
}

/// Result class for single store operations
class StoreDetailResult {
  final bool success;
  final Store? store;
  final String? error;

  StoreDetailResult({
    required this.success,
    this.store,
    this.error,
  });
}
