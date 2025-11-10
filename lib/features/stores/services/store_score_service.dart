import 'package:dio/dio.dart';
import '../../../core/services/api_config.dart';
import '../models/store_score.dart';

/// Service for fetching store review scores
class StoreScoreService {
  /// Fetch store scores with pagination
  static Future<StoreScoreResult> getStoreScores({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        '/reviews/stores/scores',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> scoresJson = response.data as List<dynamic>;
        final scores = scoresJson
            .map((json) => StoreScore.fromJson(json as Map<String, dynamic>))
            .toList();

        return StoreScoreResult(
          success: true,
          scores: scores,
          scoreMap: {for (var score in scores) score.storeId: score},
        );
      } else {
        return StoreScoreResult(
          success: false,
          error: 'Error al cargar puntuaciones (${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      return StoreScoreResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return StoreScoreResult(
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
        if (statusCode == 404) {
          return 'Puntuaciones no encontradas';
        } else if (statusCode == 500) {
          return 'Error del servidor. Intenta más tarde.';
        }
        return 'Error al procesar la solicitud (código: $statusCode)';

      case DioExceptionType.cancel:
        return 'Solicitud cancelada';

      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor. Verifica tu conexión.';

      case DioExceptionType.unknown:
        return 'Error de conexión. Intenta nuevamente.';

      default:
        return 'Error al cargar puntuaciones';
    }
  }
}

/// Result wrapper for store scores
class StoreScoreResult {
  final bool success;
  final List<StoreScore> scores;
  final Map<int, StoreScore> scoreMap;
  final String? error;

  StoreScoreResult({
    required this.success,
    this.scores = const [],
    this.scoreMap = const {},
    this.error,
  });

  /// Get score for a specific store
  StoreScore? getScoreForStore(int storeId) {
    return scoreMap[storeId];
  }

  /// Get average rating for a specific store (returns 0.0 if not found)
  double getAverageForStore(int storeId) {
    return scoreMap[storeId]?.averageRating ?? 0.0;
  }

  /// Get review count for a specific store (returns 0 if not found)
  int getReviewCountForStore(int storeId) {
    return scoreMap[storeId]?.totalReviews ?? 0;
  }
}
