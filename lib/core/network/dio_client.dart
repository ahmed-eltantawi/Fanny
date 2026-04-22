import 'package:dio/dio.dart';

/// Configured Dio HTTP client.
/// The [baseUrl] will be injected from environment / config when the real API
/// is available. All requests automatically include the auth token header.
class DioClient {
  static const String _baseUrl = 'https://api.fanny.app/v1'; // Placeholder

  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => print('[DIO] $o'),
      ),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: attach token from SharedPreferences / secure storage
    // options.headers['Authorization'] = 'Bearer $token';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Global error handling (e.g. 401 → navigate to login)
    super.onError(err, handler);
  }
}
