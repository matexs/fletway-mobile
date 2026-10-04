import 'package:freezed_annotation/freezed_annotation.dart';

part 'oferta_cliente_dto.freezed.dart';
part 'oferta_cliente_dto.g.dart';

/// Oferta como la ve el Cliente (RF-07): sin desglose ni patente.
@freezed
abstract class OfertaParaCliente with _$OfertaParaCliente {
  /// Crea la oferta; los campos espejan la API.
  const factory OfertaParaCliente({
    required String id,
    @JsonKey(name: 'transportista_id') required String transportistaId,
    @JsonKey(name: 'transportista_nombre') required String transportistaNombre,

    /// Null si el Transportista todavía no tiene reseñas.
    @JsonKey(name: 'calificacion_promedio') double? calificacionPromedio,
    @JsonKey(name: 'cantidad_resenas') required int cantidadResenas,
    @JsonKey(name: 'tasa_cumplimiento') required double tasaCumplimiento,
    @JsonKey(name: 'vehiculo_tipo') required String vehiculoTipo,
    @JsonKey(name: 'cantidad_viajes') required int cantidadViajes,
    @JsonKey(name: 'cantidad_ayudantes') required int cantidadAyudantes,
    @JsonKey(name: 'precio_calculado') required double precioCalculado,
  }) = _OfertaParaCliente;

  /// Construye la oferta desde el JSON de la API.
  factory OfertaParaCliente.fromJson(Map<String, dynamic> json) =>
      _$OfertaParaClienteFromJson(json);
}

/// Una página de las ofertas de una solicitud, ordenadas por score (RN-05).
@freezed
abstract class OfertasDeSolicitud with _$OfertasDeSolicitud {
  /// Crea la página; los campos espejan la API.
  const factory OfertasDeSolicitud({
    @JsonKey(name: 'cantidad_ayudantes_solicitados')
    required int cantidadAyudantesSolicitados,
    required int total,
    required List<OfertaParaCliente> ofertas,

    /// Desde dónde sigue "ver más", o null si no hay más.
    @JsonKey(name: 'siguiente_cursor') int? siguienteCursor,
  }) = _OfertasDeSolicitud;

  /// Construye la página desde el JSON de la API.
  factory OfertasDeSolicitud.fromJson(Map<String, dynamic> json) =>
      _$OfertasDeSolicitudFromJson(json);
}

/// Viaje que nace al aceptar una oferta. Recién acá se ve la patente.
@freezed
abstract class ViajeConfirmado with _$ViajeConfirmado {
  /// Crea el viaje; los campos espejan la API.
  const factory ViajeConfirmado({
    required String id,
    @JsonKey(name: 'solicitud_id') required String solicitudId,
    @JsonKey(name: 'transportista_id') required String transportistaId,
    @JsonKey(name: 'transportista_nombre') required String transportistaNombre,
    @JsonKey(name: 'vehiculo_patente') required String vehiculoPatente,
    @JsonKey(name: 'vehiculo_marca_modelo') String? vehiculoMarcaModelo,
    @JsonKey(name: 'monto_total') required double montoTotal,
    @JsonKey(name: 'cantidad_viajes') required int cantidadViajes,
    @JsonKey(name: 'cantidad_ayudantes') required int cantidadAyudantes,
    @JsonKey(name: 'fecha_servicio_deseada')
    required String fechaServicioDeseada,
    @JsonKey(name: 'origen_direccion') required String origenDireccion,
    @JsonKey(name: 'destino_direccion') required String destinoDireccion,
  }) = _ViajeConfirmado;

  /// Construye el viaje desde el JSON de la API.
  factory ViajeConfirmado.fromJson(Map<String, dynamic> json) =>
      _$ViajeConfirmadoFromJson(json);
}
