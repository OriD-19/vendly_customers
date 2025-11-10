import 'package:dio/dio.dart';
import '../../../core/services/api_config.dart';
import '../models/review.dart';

/// Service for managing product reviews
class ReviewService {
  /// Get all reviews for a product
  static Future<ReviewResult> getProductReviews({
    required int productId,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        '/reviews/product/$productId',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        List<dynamic> reviewsJson;
        if (data is List) {
          reviewsJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          reviewsJson = data['items'] as List<dynamic>;
        } else if (data is Map<String, dynamic> && data.containsKey('reviews')) {
          reviewsJson = data['reviews'] as List<dynamic>;
        } else {
          return ReviewResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            reviews: [],
          );
        }

        final reviews = reviewsJson
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();

        return ReviewResult(
          success: true,
          reviews: reviews,
          total: data is Map ? (data['total'] ?? reviews.length) : reviews.length,
        );
      } else {
        return ReviewResult(
          success: false,
          error: 'Error al cargar opiniones. Código: ${response.statusCode}',
          reviews: [],
        );
      }
    } on DioException catch (e) {
      return ReviewResult(
        success: false,
        error: _handleDioError(e),
        reviews: [],
      );
    } catch (e) {
      return ReviewResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        reviews: [],
      );
    }
  }

  /// Get review statistics for a product
  static Future<StatsResult> getProductReviewStats(int productId) async {
    try {
      final response = await ApiConfig.dio.get('/reviews/product/$productId/stats');

      if (response.statusCode == 200) {
        final stats = ReviewStats.fromJson(response.data);
        return StatsResult(success: true, stats: stats);
      } else {
        return StatsResult(
          success: false,
          error: 'Error al cargar estadísticas. Código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return StatsResult(success: false, error: _handleDioError(e));
    } catch (e) {
      return StatsResult(success: false, error: 'Error inesperado: ${e.toString()}');
    }
  }

  /// Get current user's review for a product
  static Future<ReviewResult> getMyReviewForProduct(int productId) async {
    try {
      final response = await ApiConfig.dio.get('/reviews/product/$productId/customer/me');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data == null || (data is Map && data.isEmpty)) {
          return ReviewResult(success: true, reviews: []);
        }

        final review = Review.fromJson(data as Map<String, dynamic>);
        return ReviewResult(success: true, reviews: [review]);
      } else if (response.statusCode == 404) {
        return ReviewResult(success: true, reviews: []);
      } else {
        return ReviewResult(
          success: false,
          error: 'Error al cargar tu opinión. Código: ${response.statusCode}',
          reviews: [],
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ReviewResult(success: true, reviews: []);
      }
      return ReviewResult(success: false, error: _handleDioError(e), reviews: []);
    } catch (e) {
      return ReviewResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        reviews: [],
      );
    }
  }

  /// Create a new review
  static Future<ReviewResult> createReview(CreateReviewRequest request) async {
    try {
      final response = await ApiConfig.dio.post(
        '/reviews/',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final review = Review.fromJson(response.data);
        return ReviewResult(success: true, reviews: [review]);
      } else {
        return ReviewResult(
          success: false,
          error: 'Error al crear opinión. Código: ${response.statusCode}',
          reviews: [],
        );
      }
    } on DioException catch (e) {
      return ReviewResult(success: false, error: _handleDioError(e), reviews: []);
    } catch (e) {
      return ReviewResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        reviews: [],
      );
    }
  }

  /// Update an existing review
  static Future<ReviewResult> updateReview({
    required int reviewId,
    required UpdateReviewRequest request,
  }) async {
    try {
      final response = await ApiConfig.dio.put(
        '/reviews/$reviewId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final review = Review.fromJson(response.data);
        return ReviewResult(success: true, reviews: [review]);
      } else {
        return ReviewResult(
          success: false,
          error: 'Error al actualizar opinión. Código: ${response.statusCode}',
          reviews: [],
        );
      }
    } on DioException catch (e) {
      return ReviewResult(success: false, error: _handleDioError(e), reviews: []);
    } catch (e) {
      return ReviewResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        reviews: [],
      );
    }
  }

  /// Delete a review
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final response = await ApiConfig.dio.delete('/reviews/$reviewId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Get all reviews by current user
  static Future<ReviewResult> getMyReviews({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        '/reviews/customer/me',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        List<dynamic> reviewsJson;
        if (data is List) {
          reviewsJson = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          reviewsJson = data['items'] as List<dynamic>;
        } else {
          return ReviewResult(
            success: false,
            error: 'Formato de respuesta inesperado',
            reviews: [],
          );
        }

        final reviews = reviewsJson
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();

        return ReviewResult(
          success: true,
          reviews: reviews,
          total: data is Map ? data['total'] : reviews.length,
        );
      } else {
        return ReviewResult(
          success: false,
          error: 'Error al cargar tus opiniones. Código: ${response.statusCode}',
          reviews: [],
        );
      }
    } on DioException catch (e) {
      return ReviewResult(success: false, error: _handleDioError(e), reviews: []);
    } catch (e) {
      return ReviewResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
        reviews: [],
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
          return 'Opinión no encontrada';
        } else if (statusCode == 403) {
          return 'No tienes permiso para realizar esta acción';
        } else if (statusCode == 400) {
          if (data is Map<String, dynamic>) {
            return data['detail'] ?? data['error'] ?? 'Datos inválidos';
          }
          return 'Datos inválidos';
        } else if (statusCode == 500) {
          return 'Error del servidor. Intenta más tarde.';
        }

        if (data is Map<String, dynamic>) {
          return data['detail'] ?? data['error'] ?? 'Error al procesar opinión';
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

/// Result class for review operations
class ReviewResult {
  final bool success;
  final List<Review> reviews;
  final String? error;
  final int? total;

  ReviewResult({
    required this.success,
    required this.reviews,
    this.error,
    this.total,
  });
}

/// Result class for stats operations
class StatsResult {
  final bool success;
  final ReviewStats? stats;
  final String? error;

  StatsResult({
    required this.success,
    this.stats,
    this.error,
  });
}
