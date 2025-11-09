import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/services/api_config.dart';
import '../models/user.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

/// Authentication service with real API integration
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  /// Initialize authentication state from storage
  /// Should be called when the app starts
  static Future<void> initialize() async {
    final token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      ApiConfig.setAuthToken(token);
    }
  }

  /// Register a new customer account
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequest(
        username: name,
        email: email,
        password: password,
        userType: 'customer',
      );

      final response = await ApiConfig.dio.post(
        ApiConfig.authRegister,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // The API returns the user object directly (not wrapped)
        final responseData = response.data as Map<String, dynamic>;
        
        // Check if there's an error in the response
        if (responseData.containsKey('error') || responseData.containsKey('detail')) {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? responseData['detail'] ?? 'Error al crear la cuenta',
          );
        }

        // Parse user from direct response
        final user = User.fromJson(responseData);
        
        // Store user data (no token for registration, will get it on login)
        await _saveUser(user);

        return AuthResult(
          success: true,
          user: user,
        );
      } else {
        return AuthResult(
          success: false,
          error: 'Error al crear la cuenta. Código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Login with username/email and password
  static Future<AuthResult> login(String usernameOrEmail, String password) async {
    try {
      final request = LoginRequest(
        username: usernameOrEmail,
        password: password,
      );

      final response = await ApiConfig.dio.post(
        ApiConfig.authLogin,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Check if there's an error in the response
        if (responseData.containsKey('error') || responseData.containsKey('detail')) {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? responseData['detail'] ?? 'Error al iniciar sesión',
          );
        }

        // Extract tokens and user data
        final accessToken = responseData['access_token'] as String?;
        final refreshToken = responseData['refresh_token'] as String?;
        final userData = responseData['user'] as Map<String, dynamic>?;

        if (accessToken != null && userData != null) {
          final user = User.fromJson(userData);

          // Store authentication data
          await _saveAuthToken(accessToken);
          ApiConfig.setAuthToken(accessToken);

          if (refreshToken != null) {
            await _saveRefreshToken(refreshToken);
          }

          await _saveUser(user);

          return AuthResult(
            success: true,
            user: user,
          );
        } else {
          return AuthResult(
            success: false,
            error: 'Respuesta del servidor incompleta',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Error al iniciar sesión. Código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Logout current user
  static Future<void> logout() async {
    try {
      await ApiConfig.dio.post(ApiConfig.authLogout);
    } catch (e) {
    } finally {
      await _clearAuthData();
      ApiConfig.clearAuthToken();
    }
  }

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    final token = await _getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current user data
  static Future<User?> getCurrentUser() async {
    return await _getUser();
  }

  /// Forgot password (to be implemented)
  static Future<bool> forgotPassword(String email) async {
    // TODO: Implement forgot password API call
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // ========== Private Helper Methods ==========

  /// Handle Dio errors and return user-friendly messages
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Verifica tu conexión.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 400) {
          // Bad request - extract error message from response
          if (data is Map<String, dynamic>) {
            return data['detail'] ?? data['error'] ?? 'Datos inválidos';
          }
          return 'Datos inválidos';
        } else if (statusCode == 401) {
          return 'Credenciales inválidas';
        } else if (statusCode == 409) {
          return 'Este correo ya está registrado';
        } else if (statusCode == 422) {
          // Validation error
          if (data is Map<String, dynamic>) {
            final detail = data['detail'];
            if (detail is List && detail.isNotEmpty) {
              final firstError = detail[0];
              if (firstError is Map) {
                return firstError['msg'] ?? 'Error de validación';
              }
            }
          }
          return 'Error de validación de datos';
        } else if (statusCode == 500) {
          return 'Error del servidor. Intenta más tarde.';
        }
        return 'Error de conexión (${statusCode ?? 'desconocido'})';

      case DioExceptionType.cancel:
        return 'Solicitud cancelada';

      case DioExceptionType.badCertificate:
        return 'Error de certificado de seguridad';

      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor. Verifica tu conexión.';

      case DioExceptionType.unknown:
        return 'Error de conexión. Intenta nuevamente.';
    }
  }

  /// Save authentication token
  static Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get authentication token
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save refresh token
  static Future<void> _saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Save user data
  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  /// Get user data
  static Future<User?> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Clear all authentication data
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }
}
