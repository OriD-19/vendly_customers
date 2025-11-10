/// Review model for API integration
class Review {
  final int id;
  final int productId;
  final int customerId;
  final String customerName;
  final String? customerAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'hace 1 mes' : 'hace $months meses';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'hace 1 semana' : 'hace $weeks semanas';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? 'hace 1 día'
          : 'hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? 'hace 1 hora'
          : 'hace ${difference.inHours} horas';
    } else {
      return 'hace unos momentos';
    }
  }

  /// Create Review from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? 'Usuario',
      customerAvatar: json['customer_avatar'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  /// Convert Review to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_avatar': customerAvatar,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Review statistics model
class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  /// Get percentage for a specific rating
  double getPercentage(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[rating] ?? 0;
    return (count / totalReviews) * 100;
  }

  /// Create ReviewStats from JSON
  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    final distribution = <int, int>{};
    
    // Parse rating distribution (can be in various formats)
    if (json['rating_distribution'] != null) {
      final dist = json['rating_distribution'];
      if (dist is Map) {
        dist.forEach((key, value) {
          final rating = int.tryParse(key.toString());
          if (rating != null) {
            distribution[rating] = value is int ? value : int.tryParse(value.toString()) ?? 0;
          }
        });
      }
    }

    // Alternative: individual star counts
    for (int i = 1; i <= 5; i++) {
      if (json['${i}_star'] != null || json['star_$i'] != null) {
        distribution[i] = json['${i}_star'] ?? json['star_$i'] ?? 0;
      }
    }

    return ReviewStats(
      averageRating: (json['average_rating'] ?? json['average'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? json['total'] ?? 0,
      ratingDistribution: distribution,
    );
  }
}

/// Create review request model
class CreateReviewRequest {
  final int productId;
  final int rating;
  final String comment;

  const CreateReviewRequest({
    required this.productId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'rating': rating,
      'comment': comment,
    };
  }
}

/// Update review request model
class UpdateReviewRequest {
  final int? rating;
  final String? comment;

  const UpdateReviewRequest({
    this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (rating != null) data['rating'] = rating;
    if (comment != null) data['comment'] = comment;
    return data;
  }
}
