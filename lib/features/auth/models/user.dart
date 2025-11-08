/// User model representing authenticated user data
class User {
  final String id;
  final String username;
  final String email;
  final String userType;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
    this.createdAt,
  });

  /// Create User from JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? 'customer',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'user_type': userType,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Convenience getter for display name
  String get displayName => username;
}
