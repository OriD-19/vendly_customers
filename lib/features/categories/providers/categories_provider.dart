import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';

/// Categories state model
class CategoriesState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriesState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  CategoriesState clearError() {
    return copyWith(error: '');
  }
}

/// Categories notifier
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  CategoriesNotifier() : super(const CategoriesState()) {
    loadCategories();
  }

  /// Load top categories
  Future<void> loadCategories({
    int limit = 5,
    String sortBy = 'count',
    String sortOrder = 'desc',
  }) async {
    state = state.copyWith(isLoading: true, error: '');

    try {
      final result = await CategoryService.getTopCategories(
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (result.success) {
        state = state.copyWith(
          categories: result.categories,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: result.error ?? 'Error al cargar categorías',
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

  /// Retry loading categories
  Future<void> retry() async {
    await loadCategories();
  }
}

/// Provider for top categories
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  return CategoriesNotifier();
});
