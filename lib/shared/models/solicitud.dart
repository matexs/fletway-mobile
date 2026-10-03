import 'package:freezed_annotation/freezed_annotation.dart';

part 'solicitud.freezed.dart';
part 'solicitud.g.dart';

/// Origen o destino de una solicitud (respuesta de la API).
@freezed
abstract class PuntoSolicitud with _$PuntoSolicitud {
  /// Crea el punto; los campos espejan la API.
  const factory PuntoSolicitud({
    @JsonKey(name: 'zona_id') required String zonaId,
    @JsonKey(name: 'zona_nombre') required String zonaNombre,
    required String direccion,
    required int pisos,
    @JsonKey(name: 'ascensor_utilizable') required bool ascensorUtilizable,
    @JsonKey(name: 'distancia_vehiculo_m') required double distanciaVehiculoM,
  }) = _PuntoSolicitud;

  /// Construye el punto desde el JSON de la API.
  factory PuntoSolicitud.fromJson(Map<String, dynamic> json) =>
      _$PuntoSolicitudFromJson(json);
}

/// Objeto de una solicitud, con los valores copiados al publicar (RN-08).
@freezed
abstract class ObjetoSolicitud with _$ObjetoSolicitud {
  /// Crea el objeto; los campos espejan la API.
  const factory ObjetoSolicitud({
    required String id,
    @JsonKey(name: 'objeto_id') String? objetoId,
    required String nombre,
    required int cantidad,
    @JsonKey(name: 'peso_unitario_kg') required double pesoUnitarioKg,
    @JsonKey(name: 'largo_m') required double largoM,
    @JsonKey(name: 'ancho_m') required double anchoM,
    @JsonKey(name: 'alto_m') required double altoM,
    @JsonKey(name: 'rotacion_horizontal') required bool rotacionHorizontal,
    @JsonKey(name: 'rotacion_vertical') required bool rotacionVertical,
    required bool apilable,
  }) = _ObjetoSolicitud;

  /// Construye el objeto desde el JSON de la API.
  factory ObjetoSolicitud.fromJson(Map<String, dynamic> json) =>
      _$ObjetoSolicitudFromJson(json);
}

/// Detalle de una solicitud (`Solicitud` en ENDPOINTS.md). No tiene ningún
/// monto: el único precio es el de cada oferta (RN-01).
@freezed
abstract class Solicitud with _$Solicitud {
  /// Crea la solicitud; los campos espejan la API.
  const factory Solicitud({
    required String id,

    /// `publicada`, `vencida`, `asignada`, `cancelada` o `expirada`.
    required String estado,
    @JsonKey(name: 'fecha_servicio_deseada')
    required String fechaServicioDeseada,
    @JsonKey(name: 'franja_horaria_inicio') String? franjaHorariaInicio,
    @JsonKey(name: 'franja_horaria_fin') String? franjaHorariaFin,
    required PuntoSolicitud origen,
    required PuntoSolicitud destino,
    @JsonKey(name: 'cantidad_ayudantes_solicitados')
    required int cantidadAyudantesSolicitados,
    required List<ObjetoSolicitud> objetos,
  }) = _Solicitud;

  /// Construye la solicitud desde el JSON de la API.
  factory Solicitud.fromJson(Map<String, dynamic> json) =>
      _$SolicitudFromJson(json);
}
