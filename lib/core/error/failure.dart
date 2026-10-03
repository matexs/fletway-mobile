import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../network/api_exception.dart';

/// Representación de un error lista para mostrar en la UI.
class Failure {
  /// Crea la falla con el [message] que ve el usuario y el [code] de origen.
  const Failure(this.message, {this.code});

  /// Texto para el usuario.
  final String message;

  /// Código estable del backend o de Supabase Auth, si lo hay.
  final String? code;

  /// Traduce un error crudo a un mensaje para el usuario. El mapeo por `code`
  /// (string estable del backend o de Supabase Auth) permite textos específicos
  /// sin parsear strings.
  factory Failure.from(Object error) {
    if (error is ApiException) {
      return Failure(
        _mensajePorCodigo(error.code) ?? error.message,
        code: error.code,
      );
    }
    if (error is AuthException) {
      return Failure(
        _mensajePorCodigoAuth(error.code) ??
            'No se pudo completar la operación. Probá de nuevo.',
        code: error.code,
      );
    }
    return const Failure('Ocurrió un error inesperado.');
  }

  static String? _mensajePorCodigo(String code) => switch (code) {
        'sin_conexion' => 'Sin conexión. Revisá tu internet.',
        'timeout' => 'La operación tardó demasiado. Probá de nuevo.',
        'no_autenticado' ||
        'token_invalido' =>
          'Tu sesión expiró. Iniciá sesión otra vez.',
        // No se sugiere registrarse de nuevo: el email ya existe en Supabase
        // Auth y el alta fallaría con user_already_exists.
        'usuario_no_encontrado' =>
          'No encontramos el perfil de tu cuenta. Cerrá sesión y escribinos '
              'para revisarla.',
        'rol_no_corresponde' => 'Tu cuenta tiene otro rol.',
        'cuenta_inactiva' => 'Tu cuenta está desactivada.',
        'transportista_no_habilitado' =>
          'Tu cuenta todavía no está habilitada para ofertar.',
        'pin_invalido' => 'El PIN ingresado no es correcto.',
        _ => null,
      };

  // Códigos de Supabase Auth:
  // https://supabase.com/docs/guides/auth/debugging/error-codes
  static String? _mensajePorCodigoAuth(String? code) => switch (code) {
        'invalid_credentials' => 'Email o contraseña incorrectos.',
        'user_already_exists' ||
        'email_exists' =>
          'Ya existe una cuenta con ese email.',
        'weak_password' => 'La contraseña es demasiado débil.',
        'email_address_invalid' => 'El email no es válido.',
        'over_request_rate_limit' ||
        'over_email_send_rate_limit' =>
          'Demasiados intentos. Esperá un momento.',
        _ => null,
      };
}
