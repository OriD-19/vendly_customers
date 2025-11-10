import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../services/product_service.dart';
import '../services/review_service.dart';

/// Product detail state model
class ProductDetailState {
  final Product? product;
  final bool isLoading;
  final String? error;
  
  // Review-related state
  final List<Review> reviews;
  final ReviewStats? reviewStats;
  final Review? myReview;
  final bool isLoadingReviews;
  final bool hasMoreReviews;

  const ProductDetailState({
    this.product,
    this.isLoading = false,
    this.error,
    this.reviews = const [],
    this.reviewStats,
    this.myReview,
    this.isLoadingReviews = false,
    this.hasMoreReviews = true,
  });

  ProductDetailState copyWith({
    Product? product,
    bool? isLoading,
    String? error,
    List<Review>? reviews,
    ReviewStats? reviewStats,
    Review? myReview,
    bool? isLoadingReviews,
    bool? hasMoreReviews,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      reviews: reviews ?? this.reviews,
      reviewStats: reviewStats ?? this.reviewStats,
      myReview: myReview ?? this.myReview,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
    );
  }

  ProductDetailState clearError() {
    return copyWith(error: '');
  }

  ProductDetailState clearMyReview() {
    return ProductDetailState(
      product: product,
      isLoading: isLoading,
      error: error,
      reviews: reviews,
      reviewStats: reviewStats,
      myReview: null,
      isLoadingReviews: isLoadingReviews,
      hasMoreReviews: hasMoreReviews,
    );
  }
}

/// Product detail notifier
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final int productId;

  ProductDetailNotifier({required this.productId}) : super(const ProductDetailState(isLoading: true)) {
    loadProduct();
  }

  /// Load product details
  Future<void> loadProduct() async {
    state = state.copyWith(isLoading: true, error: '');

    try {
      final result = await ProductService.getProductById(productId);

      if (result.success && result.products.isNotEmpty) {
        state = state.copyWith(
          product: result.products.first,
          isLoading: false,
        );

        // Load reviews, stats, and user's review
        await Future.wait([
          loadReviews(),
          loadReviewStats(),
          loadMyReview(),
        ]);
      } else {
        state = state.copyWith(
          error: result.error ?? 'No se pudo cargar el producto',
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

  /// Load product reviews
  Future<void> loadReviews({bool loadMore = false}) async {
    if (state.product == null) return;

    state = state.copyWith(isLoadingReviews: true);

    try {
      final skip = loadMore ? state.reviews.length : 0;
      final result = await ReviewService.getProductReviews(
        productId: productId,
        skip: skip,
        limit: 10,
      );

      if (result.success) {
        final newReviews = loadMore
            ? [...state.reviews, ...result.reviews]
            : result.reviews;

        state = state.copyWith(
          reviews: newReviews,
          hasMoreReviews: result.reviews.length >= 10,
          isLoadingReviews: false,
        );
      } else {
        state = state.copyWith(isLoadingReviews: false);
      }
    } catch (e) {
      state = state.copyWith(isLoadingReviews: false);
    }
  }

  /// Load review statistics
  Future<void> loadReviewStats() async {
    if (state.product == null) return;

    try {
      final result = await ReviewService.getProductReviewStats(productId);
      if (result.success && result.stats != null) {
        state = state.copyWith(reviewStats: result.stats);
      }
    } catch (e) {
      // Silently fail - stats are not critical
    }
  }

  /// Load current user's review
  Future<void> loadMyReview() async {
    if (state.product == null) return;

    try {
      final result = await ReviewService.getMyReviewForProduct(productId);
      if (result.success && result.reviews.isNotEmpty) {
        state = state.copyWith(myReview: result.reviews.first);
      }
    } catch (e) {
      // Silently fail - user may not have reviewed yet
    }
  }

  /// Create a new review
  Future<bool> createReview({
    required int rating,
    required String comment,
  }) async {
    try {
      final request = CreateReviewRequest(
        productId: productId,
        rating: rating,
        comment: comment,
      );

      final result = await ReviewService.createReview(request);

      if (result.success && result.reviews.isNotEmpty) {
        state = state.copyWith(myReview: result.reviews.first);
        
        // Reload reviews and stats
        await Future.wait([
          loadReviews(),
          loadReviewStats(),
        ]);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update existing review
  Future<bool> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final request = UpdateReviewRequest(
        rating: rating,
        comment: comment,
      );

      final result = await ReviewService.updateReview(
        reviewId: reviewId,
        request: request,
      );

      if (result.success && result.reviews.isNotEmpty) {
        state = state.copyWith(myReview: result.reviews.first);
        
        // Reload reviews and stats
        await Future.wait([
          loadReviews(),
          loadReviewStats(),
        ]);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete review
  Future<bool> deleteReview(int reviewId) async {
    try {
      final success = await ReviewService.deleteReview(reviewId);

      if (success) {
        state = state.clearMyReview();
        
        // Reload reviews and stats
        await Future.wait([
          loadReviews(),
          loadReviewStats(),
        ]);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Retry loading product
  Future<void> retry() async {
    await loadProduct();
  }
}

/// Provider family for product details (one provider per product)
final productDetailProvider = StateNotifierProvider.autoDispose.family<ProductDetailNotifier, ProductDetailState, int>(
  (ref, productId) {
    return ProductDetailNotifier(productId: productId);
  },
);
