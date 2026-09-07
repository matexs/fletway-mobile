import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../supabase/supabase_client.dart';
import 'api_exception.dart';

/// Cliente HTTP del backend Go. TODOS los endpoints requieren JWT (RNF-01);
/// el header lo agrega [AuthInterceptor] automáticamente con el token de la
/// sesión de Supabase.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  ApiClient() : _dio = Dio(_baseOptions) {
    _dio.interceptors.add(AuthInterceptor());
    if (Env.isDev) {
      _dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  final Dio _dio;

  static BaseOptions get _baseOptions => BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: Env.apiTimeout,
        receiveTimeout: Env.apiTimeout,
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      );

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) =>
      _run(() => _dio.get<T>(path, queryParameters: query));

  Future<T> post<T>(String path, {Object? body}) =>
      _run(() => _dio.post<T>(path, data: body));

  Future<T> patch<T>(String path, {Object? body}) =>
      _run(() => _dio.patch<T>(path, data: body));

  Future<T> delete<T>(String path, {Object? body}) =>
      _run(() => _dio.delete<T>(path, data: body));

  Future<T> _run<T>(Future<Response<T>> Function() call) async {
    try {
      final res = await call();
      return res.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

/// Inyecta `Authorization: Bearer <jwt>` en cada request usando el token vigente
/// de la sesión de Supabase. Un solo JWT sirve para Supabase y para el backend.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = SupabaseInit.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
