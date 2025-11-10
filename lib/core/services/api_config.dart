import 'package:dio/dio.dart';
import 'token_refresh_interceptor.dart';

class ApiConfig {
  static const String baseUrl = 'https://api.lacuponera.store';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add token refresh interceptor FIRST (so it runs before logging)
      _dio!.interceptors.add(TokenRefreshInterceptor(_dio!));

      // Add logging interceptor
      _dio!.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }

    return _dio!;
  }

  static void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  // Stores endpoints
  static const String stores = '/stores/';
  static String storeById(int id) => '/stores/$id';
  static String storeProducts(int id) => '/stores/$id/products';

  // Categories endpoints
  static const String categories = '/categories';
  static const String categoriesWithCounts = '/categories/all/with-counts';
  static String categoryById(int id) => '/categories/$id';
  static String categoryProducts(int id) => '/categories/$id/products';
}
