import 'user.dart';

/// Authentication response model
class AuthResponse {
  final bool success;
  final User? user;
  final String? token;
  final String? refreshToken;
  final String? message;
  final String? error;

  AuthResponse({
    required this.success,
    this.user,
    this.token,
    this.refreshToken,
    this.message,
    this.error,
  });

  /// Create AuthResponse from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? true,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'],
      message: json['message'],
      error: json['error'] ?? json['detail'],
    );
  }

  /// Create error response
  factory AuthResponse.error(String errorMessage) {
    return AuthResponse(
      success: false,
      error: errorMessage,
    );
  }

  /// Create success response
  factory AuthResponse.success({
    required User user,
    String? token,
    String? refreshToken,
    String? message,
  }) {
    return AuthResponse(
      success: true,
      user: user,
      token: token,
      refreshToken: refreshToken,
      message: message,
    );
  }
}

/// Legacy AuthResult for backward compatibility
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.error,
  });

  /// Create from AuthResponse
  factory AuthResult.fromAuthResponse(AuthResponse response) {
    return AuthResult(
      success: response.success,
      user: response.user,
      error: response.error,
    );
  }
}
