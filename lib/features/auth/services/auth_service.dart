/// Mock authentication service for prototype testing
class AuthService {
  static const String _trialEmail = 'demo@vendly.com';
  // static const String _trialPassword = 'demo123';
  static const String _trialName = 'Usuario Demo';

  /// Simulates user login with any credentials
  /// Returns success for any input to enable prototype testing
  static Future<AuthResult> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // For prototype: accept any credentials
    return AuthResult(
      success: true,
      user: User(
        id: '1',
        name: _trialName,
        email: email.isNotEmpty ? email : _trialEmail,
      ),
    );
  }

  /// Simulates user registration
  /// Returns success for any valid input to enable prototype testing
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // For prototype: accept any valid input
    return AuthResult(
      success: true,
      user: User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.isNotEmpty ? name : _trialName,
        email: email.isNotEmpty ? email : _trialEmail,
      ),
    );
  }

  /// Simulates logout
  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Simulates checking if user is logged in
  static Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // For prototype: return false to always show login
    return false;
  }

  /// Simulates forgot password
  static Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // For prototype: always return success
    return true;
  }
}

/// Authentication result model
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.error,
  });
}

/// User model
class User {
  final String id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });
}