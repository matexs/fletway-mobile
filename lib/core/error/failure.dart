import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, StorageException;

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
    if (error is Failure) return error;
    if (error is StorageException) {
      return Failure(
        error.statusCode == '413'
            ? 'El archivo es demasiado grande.'
            : 'No se pudo subir el archivo. Probá de nuevo.',
        code: 'storage',
      );
    }
    if (error is ApiException) {
      if (error.code == 'datos_invalidos' && error.details.isNotEmpty) {
        // El backend manda el problema de cada campo; se muestran todos juntos.
        final detalle = error.details.entries
            .map((e) => '${e.key.replaceAll('_', ' ')}: ${e.value}')
            .join('\n');
        return Failure('Revisá los datos.\n$detalle', code: error.code);
      }
      if (error.code == 'carga_no_factible' &&
          error.details['motivos'] is List) {
        // El backend explica por objeto por qué la carga no entra (RN-02).
        final motivos = (error.details['motivos'] as List)
            .map((m) => '- ${_mayuscula('$m')}')
            .join('\n');
        return Failure('La carga no entra en este vehículo:\n$motivos',
            code: error.code);
      }
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
        'archivo_no_encontrado' =>
          'No encontramos el archivo subido. Probá cargarlo de nuevo.',
        'patente_duplicada' => 'Ya hay un vehículo registrado con esa patente.',
        'tipo_vehiculo_invalido' => 'Elegí un tipo de vehículo de la lista.',
        'vehiculo_no_encontrado' => 'No encontramos ese vehículo.',
        'zona_invalida' => 'Alguna de las zonas elegidas ya no existe.',
        'fecha_pasada' => 'La fecha no puede ser anterior a hoy.',
        'objeto_invalido' => 'Algún objeto del catálogo ya no existe.',
        'direccion_no_ubicable' =>
          'No pudimos ubicar la dirección en la zona elegida.',
        'no_es_cliente' => 'Sólo un Cliente puede publicar solicitudes.',
        'solicitud_no_encontrada' => 'No encontramos esa solicitud.',
        'solicitud_no_cancelable' => 'Esta solicitud ya no se puede cancelar.',
        'solicitud_no_vencida' =>
          'Sólo se puede republicar una solicitud vencida.',
        'no_es_transportista' =>
          'Esta acción es sólo para Transportistas registrados.',
        'transportista_no_disponible' =>
          'Activá "Estoy tomando trabajos" en el inicio para ofertar.',
        'solicitud_no_disponible' =>
          'Esta solicitud ya no está disponible para ofertar.',
        'vehiculo_inactivo' => 'El vehículo está inactivo.',
        'carga_no_factible' => 'La carga no entra en este vehículo.',
        'calculo_demorado' =>
          'El cálculo de viajes tardó demasiado. Probá con un vehículo más '
              'grande.',
        'ruta_no_disponible' =>
          'No pudimos calcular el recorrido. Probá de nuevo más tarde.',
        'oferta_duplicada' =>
          'Ya tenés una oferta vigente con ese vehículo para esta solicitud.',
        'oferta_no_encontrada' => 'No encontramos esa oferta.',
        'oferta_no_retirable' => 'Sólo se puede retirar una oferta pendiente.',
        _ => null,
      };

  static String _mayuscula(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
