import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil_dto.freezed.dart';
part 'perfil_dto.g.dart';

/// Reseña pública de un viaje terminado.
@freezed
abstract class Resena with _$Resena {
  /// Crea la reseña; los campos espejan la API.
  const factory Resena({
    required int calificacion,
    String? mensaje,
    @JsonKey(name: 'cliente_nombre') required String clienteNombre,
    @JsonKey(name: 'creado_en') required DateTime creadoEn,
  }) = _Resena;

  /// Construye la reseña desde el JSON de la API.
  factory Resena.fromJson(Map<String, dynamic> json) => _$ResenaFromJson(json);
}

/// Perfil público de un Transportista (RF-11): sin contacto ni patentes.
@freezed
abstract class PerfilTransportista with _$PerfilTransportista {
  /// Crea el perfil; los campos espejan la API.
  const factory PerfilTransportista({
    required String id,
    required String nombre,
    @JsonKey(name: 'forma_trabajo') String? formaTrabajo,
    @JsonKey(name: 'calificacion_promedio') double? calificacionPromedio,
    @JsonKey(name: 'cantidad_resenas') required int cantidadResenas,
    @JsonKey(name: 'tasa_cumplimiento') required double tasaCumplimiento,
    required List<String> zonas,
    @JsonKey(name: 'tipos_vehiculo') required List<String> tiposVehiculo,
    required List<Resena> resenas,
    @JsonKey(name: 'en_fletway_desde') required DateTime enFletwayDesde,
  }) = _PerfilTransportista;

  /// Construye el perfil desde el JSON de la API.
  factory PerfilTransportista.fromJson(Map<String, dynamic> json) =>
      _$PerfilTransportistaFromJson(json);
}
