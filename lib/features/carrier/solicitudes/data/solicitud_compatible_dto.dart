import 'package:freezed_annotation/freezed_annotation.dart';

part 'solicitud_compatible_dto.freezed.dart';
part 'solicitud_compatible_dto.g.dart';

/// Solicitud que el Transportista puede ofertar (`GET /transportista/solicitudes`,
/// D-21). Sin montos: el precio se calcula al ofertar (RN-01).
@freezed
abstract class SolicitudCompatible with _$SolicitudCompatible {
  /// Crea la solicitud; los campos espejan la API.
  const factory SolicitudCompatible({
    required String id,
    @JsonKey(name: 'fecha_servicio_deseada')
    required String fechaServicioDeseada,
    @JsonKey(name: 'franja_horaria_inicio') String? franjaHorariaInicio,
    @JsonKey(name: 'franja_horaria_fin') String? franjaHorariaFin,
    @JsonKey(name: 'origen_zona_nombre') required String origenZonaNombre,
    @JsonKey(name: 'destino_zona_nombre') required String destinoZonaNombre,
    @JsonKey(name: 'cantidad_objetos') required int cantidadObjetos,
    @JsonKey(name: 'peso_total_kg') required double pesoTotalKg,
    @JsonKey(name: 'volumen_total_m3') required double volumenTotalM3,
    @JsonKey(name: 'cantidad_ayudantes_solicitados')
    required int cantidadAyudantesSolicitados,
  }) = _SolicitudCompatible;

  /// Construye la solicitud desde el JSON de la API.
  factory SolicitudCompatible.fromJson(Map<String, dynamic> json) =>
      _$SolicitudCompatibleFromJson(json);
}
