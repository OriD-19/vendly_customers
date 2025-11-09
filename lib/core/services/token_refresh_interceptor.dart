import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interceptor to handle token refresh automatically
/// When a 401 error occurs, it attempts to refresh the token and retry the request
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _authRefreshEndpoint = '/auth/refresh';
  
  // Flag to prevent multiple simultaneous refresh attempts
  static bool _isRefreshing = false;
  static final List<_RequestOptions> _pendingRequests = [];

  TokenRefreshInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      // Don't try to refresh if the failed request was already a refresh attempt
      if (err.requestOptions.path.contains(_authRefreshEndpoint)) {
        // Refresh token is also invalid, user needs to login again
        await _clearAuthData();
        return handler.reject(err);
      }

      // Don't try to refresh for login/register endpoints
      if (err.requestOptions.path.contains('/auth/login') ||
          err.requestOptions.path.contains('/auth/register')) {
        return handler.reject(err);
      }

      final requestOptions = err.requestOptions;

      // If already refreshing, queue this request
      if (_isRefreshing) {
        _pendingRequests.add(_RequestOptions(requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        // Attempt to refresh the token
        final newAccessToken = await _refreshToken();

        if (newAccessToken != null) {
          // Update the Authorization header with new token
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Retry the original request with new token
          final response = await dio.fetch(requestOptions);
          
          // Resolve all pending requests with the new token
          _resolvePendingRequests(newAccessToken);
          
          _isRefreshing = false;
          return handler.resolve(response);
        } else {
          // Refresh failed, clear auth data and reject
          await _clearAuthData();
          _rejectPendingRequests(err);
          _isRefreshing = false;
          return handler.reject(err);
        }
      } catch (e) {
        // Refresh failed, clear auth data and reject
        await _clearAuthData();
        _rejectPendingRequests(err);
        _isRefreshing = false;
        return handler.reject(err);
      }
    }

    // For other errors, just pass through
    return handler.next(err);
  }

  /// Refresh the access token using the refresh token
  Future<String?> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // Create a new Dio instance without interceptors to avoid infinite loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Call the refresh endpoint
      // Note: Adjust the request body format based on your API's requirements
      // Common formats: 
      // - {'refresh_token': refreshToken}
      // - {'token': refreshToken}
      // - Send as Bearer token in header
      final response = await refreshDio.post(
        _authRefreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final newAccessToken = responseData['access_token'] as String?;
        final newRefreshToken = responseData['refresh_token'] as String?;

        if (newAccessToken != null) {
          // Save new tokens
          await prefs.setString(_tokenKey, newAccessToken);
          if (newRefreshToken != null) {
            await prefs.setString(_refreshTokenKey, newRefreshToken);
          }

          // Update the dio instance with new token
          dio.options.headers['Authorization'] = 'Bearer $newAccessToken';

          return newAccessToken;
        }
      }

      return null;
    } catch (e) {
      print('Token refresh failed: $e');
      return null;
    }
  }

  /// Resolve all pending requests with the new token
  void _resolvePendingRequests(String newAccessToken) async {
    for (final pendingRequest in _pendingRequests) {
      try {
        pendingRequest.requestOptions.headers['Authorization'] = 
            'Bearer $newAccessToken';
        final response = await dio.fetch(pendingRequest.requestOptions);
        pendingRequest.handler.resolve(response);
      } catch (e) {
        pendingRequest.handler.reject(
          DioException(
            requestOptions: pendingRequest.requestOptions,
            error: e,
          ),
        );
      }
    }
    _pendingRequests.clear();
  }

  /// Reject all pending requests
  void _rejectPendingRequests(DioException error) {
    for (final pendingRequest in _pendingRequests) {
      pendingRequest.handler.reject(error);
    }
    _pendingRequests.clear();
  }

  /// Clear authentication data from storage
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove('user_data');
    dio.options.headers.remove('Authorization');
  }
}

/// Helper class to store pending request information
class _RequestOptions {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _RequestOptions(this.requestOptions, this.handler);
}
