import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store.dart';
import '../services/store_service.dart';
import '../services/store_score_service.dart';

/// Stores state model
class StoresState {
  final List<Store> stores;
  final bool isLoading;
  final String? error;

  const StoresState({
    this.stores = const [],
    this.isLoading = false,
    this.error,
  });

  StoresState copyWith({
    List<Store>? stores,
    bool? isLoading,
    String? error,
  }) {
    return StoresState(
      stores: stores ?? this.stores,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  StoresState clearError() {
    return copyWith(error: '');
  }
}

/// Stores notifier
class StoresNotifier extends StateNotifier<StoresState> {
  StoresNotifier() : super(const StoresState()) {
    loadStores();
  }

  /// Load all stores with their scores
  Future<void> loadStores() async {
    state = state.copyWith(isLoading: true, error: '');

    try {
      // Load stores and scores in parallel
      final results = await Future.wait([
        StoreService.getAllStores(),
        StoreScoreService.getStoreScores(skip: 0, limit: 100),
      ]);

      final storeResult = results[0] as StoreResult;
      final scoreResult = results[1] as StoreScoreResult;

      if (storeResult.success) {
        var stores = storeResult.stores;

        // Apply scores to stores if available
        if (scoreResult.success) {
          stores = stores.map((store) {
            final storeId = int.tryParse(store.id);
            if (storeId != null) {
              final score = scoreResult.getScoreForStore(storeId);
              if (score != null && score.hasReviews) {
                return store.copyWith(
                  rating: score.averageRating,
                  reviewCount: score.totalReviews,
                );
              }
            }
            return store;
          }).toList();
        }

        state = state.copyWith(
          stores: stores,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: storeResult.error ?? 'Error al cargar tiendas',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error de conexión: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Retry loading stores
  Future<void> retry() async {
    await loadStores();
  }
}

/// Provider for featured stores
final storesProvider = StateNotifierProvider<StoresNotifier, StoresState>((ref) {
  return StoresNotifier();
});
