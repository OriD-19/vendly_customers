import 'package:dio/dio.dart';
import '../../../core/services/api_config.dart';
import '../models/product.dart';

/// Service for fetching products from the API
class ProductService {
  /// Fetch products by store ID
  static Future<ProductResult> getProductsByStore({
    required int storeId,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        '/stores/$storeId/products',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle both single object and array responses
        List<dynamic> productsJson;
        if (data is List) {
          productsJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          productsJson = data['items'] as List<dynamic>;
        } else {
          return ProductResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            products: [],
          );
        }

        final products = productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        return ProductResult(
          success: true,
          products: products,
          total: data is Map ? data['total'] : products.length,
        );
      } else {
        return ProductResult(
          success: false,
          error: 'Error al cargar productos. Código: ${response.statusCode}',
          products: [],
        );
      }
    } on DioException catch (e) {
      return ProductResult(
        success: false,
        error: _handleDioError(e),
        products: [],
      );
    } catch (e) {
      return ProductResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        products: [],
      );
    }
  }

  /// Fetch products by category ID
  static Future<ProductResult> getProductsByCategory({
    required int categoryId,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        '/categories/$categoryId/products',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle both single object and array responses
        List<dynamic> productsJson;
        if (data is List) {
          productsJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          productsJson = data['items'] as List<dynamic>;
        } else {
          return ProductResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            products: [],
          );
        }

        final products = productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        return ProductResult(
          success: true,
          products: products,
          total: data is Map ? data['total'] : products.length,
        );
      } else {
        return ProductResult(
          success: false,
          error: 'Error al cargar productos. Código: ${response.statusCode}',
          products: [],
        );
      }
    } on DioException catch (e) {
      return ProductResult(
        success: false,
        error: _handleDioError(e),
        products: [],
      );
    } catch (e) {
      return ProductResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        products: [],
      );
    }
  }

  /// Search products across all categories
  static Future<ProductResult> searchProducts({
    required String query,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        '/products/search',
        queryParameters: {
          'q': query,
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        List<dynamic> productsJson;
        if (data is List) {
          productsJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          productsJson = data['items'] as List<dynamic>;
        } else {
          return ProductResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            products: [],
          );
        }

        final products = productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        return ProductResult(
          success: true,
          products: products,
          total: data is Map ? data['total'] : products.length,
        );
      } else {
        return ProductResult(
          success: false,
          error: 'Error en la búsqueda. Código: ${response.statusCode}',
          products: [],
        );
      }
    } on DioException catch (e) {
      return ProductResult(
        success: false,
        error: _handleDioError(e),
        products: [],
      );
    } catch (e) {
      return ProductResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        products: [],
      );
    }
  }

  /// Fetch a single product by ID
  static Future<ProductResult> getProductById(int productId) async {
    try {
      final response = await ApiConfig.dio.get('/products/$productId');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          final product = Product.fromJson(data);
          return ProductResult(
            success: true,
            products: [product],
            total: 1,
          );
        } else {
          return ProductResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            products: [],
          );
        }
      } else {
        return ProductResult(
          success: false,
          error: 'Error al cargar producto. Código: ${response.statusCode}',
          products: [],
        );
      }
    } on DioException catch (e) {
      return ProductResult(
        success: false,
        error: _handleDioError(e),
        products: [],
      );
    } catch (e) {
      return ProductResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        products: [],
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
          return 'Productos no encontrados';
        } else if (statusCode == 500) {
          return 'Error del servidor. Intenta más tarde.';
        }
        
        if (data is Map<String, dynamic>) {
          return data['detail'] ?? data['error'] ?? 'Error al cargar productos';
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

/// Result class for product operations
class ProductResult {
  final bool success;
  final List<Product> products;
  final String? error;
  final int? total;

  ProductResult({
    required this.success,
    required this.products,
    this.error,
    this.total,
  });
}
