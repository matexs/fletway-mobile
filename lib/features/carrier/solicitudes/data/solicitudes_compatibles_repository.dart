import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/models/solicitud.dart';
import 'solicitud_compatible_dto.dart';

/// Repositorio de solicitudes compatibles. Depende de [apiClientProvider].
final solicitudesCompatiblesRepositoryProvider =
    Provider<SolicitudesCompatiblesRepository>(
  (ref) => SolicitudesCompatiblesRepository(ref.watch(apiClientProvider)),
);

/// Solicitudes que el Transportista puede ofertar (RN-04, D-21). Lanza
/// `ApiException`.
class SolicitudesCompatiblesRepository {
  /// Crea el repositorio sobre [ApiClient].
  SolicitudesCompatiblesRepository(this._api);

  final ApiClient _api;

  /// `GET /transportista/solicitudes`, las de fecha más cercana primero.
  Future<List<SolicitudCompatible>> compatibles() async {
    final json = await _api.get<List<dynamic>>('/transportista/solicitudes');
    return json
        .map((e) => SolicitudCompatible.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /solicitudes/{id}`: detalle con direcciones y objetos.
  Future<Solicitud> detalle(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/solicitudes/$id');
    return Solicitud.fromJson(json);
  }
}
