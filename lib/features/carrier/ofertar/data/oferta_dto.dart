import 'package:freezed_annotation/freezed_annotation.dart';

part 'oferta_dto.freezed.dart';
part 'oferta_dto.g.dart';

/// Detalle del precio de una oferta (RN-01). Sólo lo ven el Transportista
/// dueño y el Administrador (D-23).
@freezed
abstract class DesgloseOferta with _$DesgloseOferta {
  /// Crea el desglose; los campos espejan la API.
  const factory DesgloseOferta({
    @JsonKey(name: 'distancia_km') required double distanciaKm,
    @JsonKey(name: 'duracion_ruta_h') required double duracionRutaH,
    @JsonKey(name: 'duracion_operacion_h') required double duracionOperacionH,
    @JsonKey(name: 'costo_laboral') required double costoLaboral,
    @JsonKey(name: 'costo_vehiculo') required double costoVehiculo,
    @JsonKey(name: 'costos_adicionales') required double costosAdicionales,
    @JsonKey(name: 'costo_operativo') required double costoOperativo,
    @JsonKey(name: 'margen_pct') required double margenPct,
    @JsonKey(name: 'precio_neto') required double precioNeto,
    @JsonKey(name: 'porcentaje_comision') required double porcentajeComision,
    @JsonKey(name: 'iva_pct') required double ivaPct,
  }) = _DesgloseOferta;

  /// Construye el desglose desde el JSON de la API.
  factory DesgloseOferta.fromJson(Map<String, dynamic> json) =>
      _$DesgloseOfertaFromJson(json);
}

/// Precio y viajes que tendría una oferta, sin guardarla
/// (`POST /solicitudes/{id}/ofertas/cotizar`).
@freezed
abstract class Cotizacion with _$Cotizacion {
  /// Crea la cotización; los campos espejan la API.
  const factory Cotizacion({
    @JsonKey(name: 'cantidad_viajes') required int cantidadViajes,
    @JsonKey(name: 'cantidad_ayudantes') required int cantidadAyudantes,

    /// Lo que paga el Cliente, con IVA.
    @JsonKey(name: 'precio_calculado') required double precioCalculado,
    required DesgloseOferta desglose,
  }) = _Cotizacion;

  /// Construye la cotización desde el JSON de la API.
  factory Cotizacion.fromJson(Map<String, dynamic> json) =>
      _$CotizacionFromJson(json);
}

/// Oferta del Transportista (`Oferta` en ENDPOINTS.md).
@freezed
abstract class Oferta with _$Oferta {
  /// Crea la oferta; los campos espejan la API.
  const factory Oferta({
    required String id,

    /// `pendiente`, `aceptada`, `no_seleccionada` o `retirada`.
    required String estado,
    @JsonKey(name: 'solicitud_id') required String solicitudId,

    /// Estado de la solicitud, con `vencida` calculado al leer (D-20).
    @JsonKey(name: 'solicitud_estado') required String solicitudEstado,
    @JsonKey(name: 'fecha_servicio_deseada')
    required String fechaServicioDeseada,
    @JsonKey(name: 'origen_zona_nombre') required String origenZonaNombre,
    @JsonKey(name: 'destino_zona_nombre') required String destinoZonaNombre,
    @JsonKey(name: 'vehiculo_id') required String vehiculoId,
    @JsonKey(name: 'vehiculo_patente') required String vehiculoPatente,
    @JsonKey(name: 'vehiculo_tipo') required String vehiculoTipo,
    @JsonKey(name: 'cantidad_viajes') required int cantidadViajes,
    @JsonKey(name: 'cantidad_ayudantes') required int cantidadAyudantes,
    @JsonKey(name: 'precio_calculado') required double precioCalculado,
    required DesgloseOferta desglose,
  }) = _Oferta;

  /// Construye la oferta desde el JSON de la API.
  factory Oferta.fromJson(Map<String, dynamic> json) => _$OfertaFromJson(json);
}
