/// Registration request model
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String userType;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.userType = 'customer',
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'user_type': userType,
    };
  }
}

/// Login request model
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
