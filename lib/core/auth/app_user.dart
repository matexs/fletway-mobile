import '../../shared/models/me.dart';

/// Rol de la cuenta (`usuario.rol`). Un rol por cuenta (D-17). El Administrador
/// no usa esta app (opera por Postman en esta etapa, D-17).
enum UserRole {
  /// Publica solicitudes (RF-05..RF-15).
  cliente,

  /// Ofrece el servicio (RF-16..RF-24).
  transportista,

  /// Personal interno; la app no tiene vistas para este rol.
  administrador,
}

/// Estado de habilitación del Transportista (RF-01).
enum EstadoHabilitacion {
  /// Registrado, con la documentación sin aprobar.
  pendiente,

  /// Puede ofertar.
  habilitado,

  /// Documentación rechazada; puede volver a cargarla.
  rechazado,
}

/// Usuario autenticado, construido desde `GET /api/me` (D-18).
class AppUser {
  /// Crea el usuario; usar [AppUser.fromMe] para construirlo desde la API.
  const AppUser({
    required this.id,
    required this.email,
    required this.nombreCompleto,
    required this.telefono,
    required this.role,
    this.estadoHabilitacion,
  });

  /// Construye el usuario desde el perfil de la API. Lanza [FormatException] si
  /// el rol o el estado de habilitación no son valores conocidos.
  factory AppUser.fromMe(Me me) => AppUser(
        id: me.usuarioId,
        email: me.email,
        nombreCompleto: me.nombreCompleto,
        telefono: me.telefono,
        role: _enumPorNombre(UserRole.values, me.rol, 'rol'),
        estadoHabilitacion: me.estadoHabilitacion == null
            ? null
            : _enumPorNombre(
                EstadoHabilitacion.values,
                me.estadoHabilitacion!,
                'estado_habilitacion',
              ),
      );

  /// `usuario.id` == `auth.uid()`.
  final String id;

  /// Email de la cuenta.
  final String email;

  /// Nombre y apellido.
  final String nombreCompleto;

  /// Teléfono de contacto.
  final String telefono;

  /// Rol de la cuenta, según `usuario.rol`.
  final UserRole role;

  /// Sólo para Transportistas; null para los otros roles.
  final EstadoHabilitacion? estadoHabilitacion;

  /// true si la cuenta es de Cliente.
  bool get esCliente => role == UserRole.cliente;

  /// true si la cuenta es de Transportista.
  bool get esTransportista => role == UserRole.transportista;

  /// Copia del usuario con otro [estado] de habilitación.
  AppUser conEstadoHabilitacion(EstadoHabilitacion estado) => AppUser(
        id: id,
        email: email,
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        role: role,
        estadoHabilitacion: estado,
      );

  /// Convierte el código de la API (`pendiente`, `habilitado`, `rechazado`) en
  /// [EstadoHabilitacion]. Lanza [FormatException] si no lo conoce.
  static EstadoHabilitacion estadoDesdeCodigo(String codigo) =>
      _enumPorNombre(EstadoHabilitacion.values, codigo, 'estado_habilitacion');

  /// Sólo un Transportista habilitado puede ofertar (RF-01, RF-17).
  bool get puedeOfertar =>
      esTransportista && estadoHabilitacion == EstadoHabilitacion.habilitado;

  static T _enumPorNombre<T extends Enum>(
    List<T> valores,
    String nombre,
    String campo,
  ) {
    for (final v in valores) {
      if (v.name == nombre) return v;
    }
    throw FormatException('valor desconocido en $campo: $nombre');
  }
}
