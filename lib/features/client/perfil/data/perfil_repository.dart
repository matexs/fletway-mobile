import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import 'perfil_dto.dart';

/// Repositorio de perfiles públicos. Depende de [apiClientProvider].
final perfilTransportistaRepositoryProvider =
    Provider<PerfilTransportistaRepository>(
  (ref) => PerfilTransportistaRepository(ref.watch(apiClientProvider)),
);

/// Perfiles públicos de Transportistas (RF-11). Lanza `ApiException`.
class PerfilTransportistaRepository {
  /// Crea el repositorio sobre [ApiClient].
  PerfilTransportistaRepository(this._api);

  final ApiClient _api;

  /// `GET /transportistas/{id}`.
  Future<PerfilTransportista> perfil(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/transportistas/$id');
    return PerfilTransportista.fromJson(json);
  }
}
