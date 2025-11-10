/// Store score model representing the average rating from reviews
class StoreScore {
  final int storeId;
  final String storeName;
  final double averageRating;
  final int totalReviews;

  const StoreScore({
    required this.storeId,
    required this.storeName,
    required this.averageRating,
    required this.totalReviews,
  });

  /// Create StoreScore from JSON response
  factory StoreScore.fromJson(Map<String, dynamic> json) {
    return StoreScore(
      storeId: json['store_id'] ?? 0,
      storeName: json['store_name'] ?? '',
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'store_name': storeName,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }

  /// Check if store has reviews
  bool get hasReviews => totalReviews > 0;

  /// Get formatted average rating
  String get formattedRating => averageRating.toStringAsFixed(1);
}
