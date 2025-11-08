import 'package:dio/dio.dart';
import '../../../core/services/api_config.dart';
import '../models/category.dart';

/// Service for fetching categories from the API
class CategoryService {
  /// Fetch top categories with product counts
  /// Uses the /categories/all/with-counts endpoint
  static Future<CategoryResult> getTopCategories({
    int limit = 5,
    String sortBy = 'count',
    String sortOrder = 'desc',
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        ApiConfig.categoriesWithCounts,
        queryParameters: {
          'limit': limit,
          'sort_by': sortBy,
          'sort_order': sortOrder,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle both single object and array responses
        List<dynamic> categoriesJson;
        if (data is List) {
          categoriesJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          categoriesJson = data['items'] as List<dynamic>;
        } else {
          return CategoryResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            categories: [],
          );
        }

        final categories = categoriesJson
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();

        return CategoryResult(
          success: true,
          categories: categories,
          total: data is Map ? data['total'] : categories.length,
        );
      } else {
        return CategoryResult(
          success: false,
          error: 'Error al cargar categorías. Código: ${response.statusCode}',
          categories: [],
        );
      }
    } on DioException catch (e) {
      return CategoryResult(
        success: false,
        error: _handleDioError(e),
        categories: [],
      );
    } catch (e) {
      return CategoryResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        categories: [],
      );
    }
  }

  /// Fetch all categories with optional pagination
  static Future<CategoryResult> getAllCategories({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        ApiConfig.categories,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        List<dynamic> categoriesJson;
        if (data is List) {
          categoriesJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          categoriesJson = data['items'] as List<dynamic>;
        } else {
          return CategoryResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            categories: [],
          );
        }

        final categories = categoriesJson
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();

        return CategoryResult(
          success: true,
          categories: categories,
          total: data is Map ? data['total'] : categories.length,
        );
      } else {
        return CategoryResult(
          success: false,
          error: 'Error al cargar categorías. Código: ${response.statusCode}',
          categories: [],
        );
      }
    } on DioException catch (e) {
      return CategoryResult(
        success: false,
        error: _handleDioError(e),
        categories: [],
      );
    } catch (e) {
      return CategoryResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        categories: [],
      );
    }
  }

  /// Fetch a specific category by ID
  static Future<CategoryDetailResult> getCategoryById(int id) async {
    try {
      final response = await ApiConfig.dio.get(ApiConfig.categoryById(id));

      if (response.statusCode == 200) {
        final category = Category.fromJson(response.data as Map<String, dynamic>);
        return CategoryDetailResult(
          success: true,
          category: category,
        );
      } else {
        return CategoryDetailResult(
          success: false,
          error: 'Error al cargar la categoría. Código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return CategoryDetailResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return CategoryDetailResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
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
          return 'Categoría no encontrada';
        } else if (statusCode == 500) {
          return 'Error del servidor. Intenta más tarde.';
        }
        
        if (data is Map<String, dynamic>) {
          return data['detail'] ?? data['error'] ?? 'Error al cargar categorías';
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

/// Result class for category list operations
class CategoryResult {
  final bool success;
  final List<Category> categories;
  final String? error;
  final int? total;

  CategoryResult({
    required this.success,
    required this.categories,
    this.error,
    this.total,
  });
}

/// Result class for single category operations
class CategoryDetailResult {
  final bool success;
  final Category? category;
  final String? error;

  CategoryDetailResult({
    required this.success,
    this.category,
    this.error,
  });
}
