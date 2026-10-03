import 'package:freezed_annotation/freezed_annotation.dart';

part 'me.freezed.dart';
part 'me.g.dart';

/// Perfil del usuario autenticado que devuelven `GET /api/me` y los endpoints de
/// registro (`../fletway-backend/docs/ENDPOINTS.md`, "Respuesta Me"). Es la única
/// fuente del rol en la app (D-18): nunca se usa el rol de `user_metadata`.
@freezed
abstract class Me with _$Me {
  /// Crea el perfil; los campos espejan la respuesta de la API.
  const factory Me({
    @JsonKey(name: 'usuario_id') required String usuarioId,
    required String email,
    @JsonKey(name: 'nombre_completo') required String nombreCompleto,
    required String telefono,

    /// `cliente`, `transportista` o `administrador`.
    required String rol,
    required bool activo,

    /// false mientras falte la fila del rol: hay que llamar al registro.
    @JsonKey(name: 'registro_completo') required bool registroCompleto,

    /// Estado del Transportista (`pendiente`, `habilitado`, `rechazado`); null
    /// para los otros roles.
    @JsonKey(name: 'estado_habilitacion') String? estadoHabilitacion,
  }) = _Me;

  /// Construye el perfil desde el JSON de la API.
  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);
}
