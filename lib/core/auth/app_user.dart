/// Rol del usuario en la app móvil. El Administrador (RF-01..RF-04) NO usa esta
/// app — su frente es la futura web admin.
enum UserRole { cliente, transportista }

/// Estado de habilitación del Transportista (RF-01). Para el Cliente es siempre
/// [habilitado] (no aplica).
enum EstadoHabilitacion { pendiente, habilitado, rechazado }

/// Usuario autenticado, derivado de la sesión de Supabase Auth
/// (`auth.uid()` == `usuario.id`) + el perfil que devuelve el backend.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.nombreCompleto,
    required this.role,
    this.estadoHabilitacion = EstadoHabilitacion.habilitado,
  });

  final String id;
  final String email;
  final String nombreCompleto;
  final UserRole role;
  final EstadoHabilitacion estadoHabilitacion;

  bool get esCliente => role == UserRole.cliente;
  bool get esTransportista => role == UserRole.transportista;

  /// Solo un Transportista habilitado puede ofertar (RF-01 / RF-17).
  bool get puedeOfertar =>
      esTransportista && estadoHabilitacion == EstadoHabilitacion.habilitado;

  AppUser copyWith({
    UserRole? role,
    EstadoHabilitacion? estadoHabilitacion,
    String? nombreCompleto,
  }) =>
      AppUser(
        id: id,
        email: email,
        nombreCompleto: nombreCompleto ?? this.nombreCompleto,
        role: role ?? this.role,
        estadoHabilitacion: estadoHabilitacion ?? this.estadoHabilitacion,
      );
}
