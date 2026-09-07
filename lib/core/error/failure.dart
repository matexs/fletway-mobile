import '../network/api_exception.dart';

/// Representación de un error lista para mostrar en la UI.
class Failure {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  /// Traduce un error crudo a un mensaje para el usuario. El mapeo por `code`
  /// (string estable del backend) permite textos específicos sin parsear strings.
  factory Failure.from(Object error) {
    if (error is ApiException) {
      return Failure(_mensajePorCodigo(error.code) ?? error.message,
          code: error.code);
    }
    return const Failure('Ocurrió un error inesperado.');
  }

  static String? _mensajePorCodigo(String code) => switch (code) {
        'sin_conexion' => 'Sin conexión. Revisá tu internet.',
        'timeout' => 'La operación tardó demasiado. Probá de nuevo.',
        'no_autenticado' ||
        'token_invalido' =>
          'Tu sesión expiró. Iniciá sesión otra vez.',
        'transportista_no_habilitado' =>
          'Tu cuenta todavía no está habilitada para ofertar.',
        'pin_invalido' => 'El PIN ingresado no es correcto.',
        _ => null,
      };
}
