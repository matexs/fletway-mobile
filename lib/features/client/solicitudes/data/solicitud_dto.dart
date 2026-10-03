import 'package:freezed_annotation/freezed_annotation.dart';

part 'solicitud_dto.freezed.dart';
part 'solicitud_dto.g.dart';

/// Solicitud en el listado del Cliente.
@freezed
abstract class SolicitudResumen with _$SolicitudResumen {
  /// Crea el resumen; los campos espejan la API.
  const factory SolicitudResumen({
    required String id,
    required String estado,
    @JsonKey(name: 'fecha_servicio_deseada')
    required String fechaServicioDeseada,
    @JsonKey(name: 'franja_horaria_inicio') String? franjaHorariaInicio,
    @JsonKey(name: 'franja_horaria_fin') String? franjaHorariaFin,
    @JsonKey(name: 'origen_zona_nombre') required String origenZonaNombre,
    @JsonKey(name: 'destino_zona_nombre') required String destinoZonaNombre,
    @JsonKey(name: 'cantidad_objetos') required int cantidadObjetos,
  }) = _SolicitudResumen;

  /// Construye el resumen desde el JSON de la API.
  factory SolicitudResumen.fromJson(Map<String, dynamic> json) =>
      _$SolicitudResumenFromJson(json);
}

/// Origen o destino de una solicitud nueva (request).
@freezed
abstract class PuntoNuevo with _$PuntoNuevo {
  /// Crea el punto con lo que ingresa el Cliente.
  const factory PuntoNuevo({
    @JsonKey(name: 'zona_id') required String zonaId,
    required String direccion,
    required int pisos,
    @JsonKey(name: 'ascensor_utilizable') required bool ascensorUtilizable,
    @JsonKey(name: 'distancia_vehiculo_m') required double distanciaVehiculoM,
  }) = _PuntoNuevo;

  /// Construye el punto desde JSON (para tests).
  factory PuntoNuevo.fromJson(Map<String, dynamic> json) =>
      _$PuntoNuevoFromJson(json);
}

/// Objeto de una solicitud nueva: del catálogo (sólo [objetoId] y [cantidad]) o
/// cargado a mano (nombre, peso y medidas). El backend trata un campo null como
/// ausente.
@freezed
abstract class ObjetoNuevo with _$ObjetoNuevo {
  /// Crea el objeto. Si es del catálogo, el backend copia peso, medidas y
  /// restricciones.
  const factory ObjetoNuevo({
    @JsonKey(name: 'objeto_id') String? objetoId,
    @JsonKey(name: 'nombre_personalizado') String? nombrePersonalizado,
    required int cantidad,
    @JsonKey(name: 'peso_unitario_kg') double? pesoUnitarioKg,
    @JsonKey(name: 'largo_m') double? largoM,
    @JsonKey(name: 'ancho_m') double? anchoM,
    @JsonKey(name: 'alto_m') double? altoM,
    @JsonKey(name: 'rotacion_horizontal') bool? rotacionHorizontal,
    @JsonKey(name: 'rotacion_vertical') bool? rotacionVertical,
    bool? apilable,
  }) = _ObjetoNuevo;

  /// Construye el objeto desde JSON (para tests).
  factory ObjetoNuevo.fromJson(Map<String, dynamic> json) =>
      _$ObjetoNuevoFromJson(json);
}

/// Alta de una solicitud (`POST /solicitudes`, RF-06). No lleva montos.
@freezed
abstract class NuevaSolicitud with _$NuevaSolicitud {
  /// Crea el request.
  const factory NuevaSolicitud({
    required PuntoNuevo origen,
    required PuntoNuevo destino,
    @JsonKey(name: 'fecha_servicio_deseada')
    required String fechaServicioDeseada,
    @JsonKey(name: 'franja_horaria_inicio') String? franjaHorariaInicio,
    @JsonKey(name: 'franja_horaria_fin') String? franjaHorariaFin,
    @JsonKey(name: 'cantidad_ayudantes_solicitados')
    required int cantidadAyudantesSolicitados,
    required List<ObjetoNuevo> objetos,
  }) = _NuevaSolicitud;

  /// Construye el request desde JSON (para tests).
  factory NuevaSolicitud.fromJson(Map<String, dynamic> json) =>
      _$NuevaSolicitudFromJson(json);
}
