import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import 'vehiculo_dto.dart';

/// Repositorio de vehículos del Transportista. Depende de [apiClientProvider].
final vehiculoRepositoryProvider = Provider<VehiculoRepository>(
  (ref) => VehiculoRepository(ref.watch(apiClientProvider)),
);

/// Vehículos y costos contra el backend (RF-18, RN-01). Todos los métodos lanzan
/// `ApiException`.
class VehiculoRepository {
  /// Crea el repositorio sobre [ApiClient].
  VehiculoRepository(this._api);

  final ApiClient _api;

  /// `GET /tipos-vehiculo`.
  Future<List<TipoVehiculo>> tipos() async {
    final json = await _api.get<List<dynamic>>('/tipos-vehiculo');
    return json
        .map((e) => TipoVehiculo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /transportista/vehiculos`.
  Future<List<Vehiculo>> propios() async {
    final json = await _api.get<List<dynamic>>('/transportista/vehiculos');
    return json
        .map((e) => Vehiculo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /transportista/vehiculos`. Errores esperables: `datos_invalidos`
  /// (con el detalle por campo) y `patente_duplicada`.
  Future<Vehiculo> crear(NuevoVehiculo nuevo) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/transportista/vehiculos',
      body: nuevo.toJson(),
    );
    return Vehiculo.fromJson(json);
  }

  /// `PUT /transportista/vehiculos/{id}/activo`.
  Future<Vehiculo> cambiarActivo(String id, {required bool activo}) async {
    final json = await _api.put<Map<String, dynamic>>(
      '/transportista/vehiculos/$id/activo',
      body: {'activo': activo},
    );
    return Vehiculo.fromJson(json);
  }

  /// `GET /transportista/vehiculos/{id}/costos`. Devuelve null si todavía no se
  /// cargaron (`costos_no_cargados`).
  Future<CostosVehiculo?> costos(String id) async {
    try {
      final json = await _api.get<Map<String, dynamic>>(
        '/transportista/vehiculos/$id/costos',
      );
      return CostosVehiculo.fromJson(json);
    } on ApiException catch (e) {
      if (e.code == 'costos_no_cargados') return null;
      rethrow;
    }
  }

  /// `PUT /transportista/vehiculos/{id}/costos`: crea o reemplaza.
  Future<CostosVehiculo> guardarCostos(String id, CostosVehiculo costos) async {
    final json = await _api.put<Map<String, dynamic>>(
      '/transportista/vehiculos/$id/costos',
      body: costos.toJson(),
    );
    return CostosVehiculo.fromJson(json);
  }
}
