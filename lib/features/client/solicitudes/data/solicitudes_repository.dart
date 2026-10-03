import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/models/zona.dart';
import 'solicitud_dto.dart';

/// Repositorio de solicitudes del Cliente. Depende de [apiClientProvider].
final solicitudesRepositoryProvider = Provider<SolicitudesRepository>(
  (ref) => SolicitudesRepository(ref.watch(apiClientProvider)),
);

/// Publicación y seguimiento de solicitudes (RF-06, D-20). Todos los métodos
/// lanzan `ApiException`.
class SolicitudesRepository {
  /// Crea el repositorio sobre [ApiClient].
  SolicitudesRepository(this._api);

  final ApiClient _api;

  /// `GET /zonas`, para elegir origen y destino.
  Future<List<Zona>> zonas() async {
    final json = await _api.get<List<dynamic>>('/zonas');
    return json.map((e) => Zona.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// `POST /solicitudes`.
  Future<Solicitud> publicar(NuevaSolicitud nueva) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/solicitudes',
      body: nueva.toJson(),
    );
    return Solicitud.fromJson(json);
  }

  /// `GET /solicitudes`: las propias, las más nuevas primero.
  Future<List<SolicitudResumen>> propias() async {
    final json = await _api.get<List<dynamic>>('/solicitudes');
    return json
        .map((e) => SolicitudResumen.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /solicitudes/{id}`.
  Future<Solicitud> detalle(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/solicitudes/$id');
    return Solicitud.fromJson(json);
  }

  /// `POST /solicitudes/{id}/cancelar`.
  Future<Solicitud> cancelar(String id) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/solicitudes/$id/cancelar',
    );
    return Solicitud.fromJson(json);
  }

  /// `POST /solicitudes/{id}/republicar` con la fecha nueva (`AAAA-MM-DD`) y
  /// la franja opcional (`HH:MM`). Devuelve la solicitud nueva.
  Future<Solicitud> republicar(
    String id, {
    required String fecha,
    String? franjaInicio,
    String? franjaFin,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/solicitudes/$id/republicar',
      body: {
        'fecha_servicio_deseada': fecha,
        'franja_horaria_inicio': franjaInicio,
        'franja_horaria_fin': franjaFin,
      },
    );
    return Solicitud.fromJson(json);
  }
}
