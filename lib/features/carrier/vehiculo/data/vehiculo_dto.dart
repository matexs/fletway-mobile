import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehiculo_dto.freezed.dart';
part 'vehiculo_dto.g.dart';

/// Tipo de vehículo con sus medidas estándar de referencia (D-32): se proponen
/// al registrar un vehículo y el Transportista las corrige.
@freezed
abstract class TipoVehiculo with _$TipoVehiculo {
  /// Crea el tipo; los campos espejan `GET /tipos-vehiculo`.
  const factory TipoVehiculo({
    required String id,
    required String nombre,
    @JsonKey(name: 'largo_estandar_m') required double largoEstandarM,
    @JsonKey(name: 'ancho_estandar_m') required double anchoEstandarM,
    @JsonKey(name: 'alto_estandar_m') required double altoEstandarM,
    @JsonKey(name: 'peso_maximo_estandar_kg')
    required double pesoMaximoEstandarKg,
  }) = _TipoVehiculo;

  /// Construye el tipo desde el JSON de la API.
  factory TipoVehiculo.fromJson(Map<String, dynamic> json) =>
      _$TipoVehiculoFromJson(json);
}

/// Vehículo del Transportista (`Vehiculo` en ENDPOINTS.md).
@freezed
abstract class Vehiculo with _$Vehiculo {
  /// Crea el vehículo; los campos espejan la API.
  const factory Vehiculo({
    required String id,
    @JsonKey(name: 'tipo_vehiculo_id') required String tipoVehiculoId,
    @JsonKey(name: 'tipo_vehiculo_nombre') required String tipoVehiculoNombre,
    required String patente,
    String? marca,
    String? modelo,
    @JsonKey(name: 'largo_util_m') required double largoUtilM,
    @JsonKey(name: 'ancho_util_m') required double anchoUtilM,
    @JsonKey(name: 'alto_util_m') required double altoUtilM,

    /// Carga útil, no peso bruto.
    @JsonKey(name: 'peso_maximo_kg') required double pesoMaximoKg,
    required bool activo,
  }) = _Vehiculo;

  /// Construye el vehículo desde el JSON de la API.
  factory Vehiculo.fromJson(Map<String, dynamic> json) =>
      _$VehiculoFromJson(json);
}

/// Alta de un vehículo (`POST /transportista/vehiculos`).
@freezed
abstract class NuevoVehiculo with _$NuevoVehiculo {
  /// Crea el request con lo que ingresa el Transportista.
  const factory NuevoVehiculo({
    @JsonKey(name: 'tipo_vehiculo_id') required String tipoVehiculoId,
    required String patente,
    String? marca,
    String? modelo,
    @JsonKey(name: 'largo_util_m') required double largoUtilM,
    @JsonKey(name: 'ancho_util_m') required double anchoUtilM,
    @JsonKey(name: 'alto_util_m') required double altoUtilM,
    @JsonKey(name: 'peso_maximo_kg') required double pesoMaximoKg,
  }) = _NuevoVehiculo;

  /// Construye el request desde JSON (para tests).
  factory NuevoVehiculo.fromJson(Map<String, dynamic> json) =>
      _$NuevoVehiculoFromJson(json);
}
