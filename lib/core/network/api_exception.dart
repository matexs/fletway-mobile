import 'package:dio/dio.dart';

/// Representa el envelope de error único del backend Go:
/// `{ "error": { "code": "...", "message": "...", "details": {...} } }`
/// (ver ../fletway-backend/docs/DECISIONES_TECNICAS.md D-11).
class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details = const {},
  });

  /// Código estable en snake_case español (`solicitud_no_encontrada`,
  /// `transportista_no_habilitado`, `pin_invalido`, …). Usarlo para decidir el
  /// texto que ve el usuario, no el `message` crudo.
  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic> details;

  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    final data = response?.data;
    if (data is Map && data['error'] is Map) {
      final err = (data['error'] as Map).cast<String, dynamic>();
      return ApiException(
        code: (err['code'] as String?) ?? 'error_desconocido',
        message: (err['message'] as String?) ?? 'Ocurrió un error.',
        statusCode: response?.statusCode,
        details: (err['details'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
    }
    return ApiException(
      code: switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'timeout',
        DioExceptionType.connectionError => 'sin_conexion',
        _ => 'error_desconocido',
      },
      message: e.message ?? 'No se pudo completar la operación.',
      statusCode: response?.statusCode,
    );
  }

  bool get isAuth =>
      statusCode == 401 || code == 'no_autenticado' || code == 'token_invalido';

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
