import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/models/zona.dart';

/// Repositorio de zonas. Depende de [apiClientProvider].
final zonasRepositoryProvider = Provider<ZonasRepository>(
  (ref) => ZonasRepository(ref.watch(apiClientProvider)),
);

/// Catálogo de zonas y zonas de trabajo del Transportista (RN-04). Lanza
/// `ApiException`.
class ZonasRepository {
  /// Crea el repositorio sobre [ApiClient].
  ZonasRepository(this._api);

  final ApiClient _api;

  /// `GET /zonas`, ordenado por provincia y nombre.
  Future<List<Zona>> catalogo() async {
    final json = await _api.get<List<dynamic>>('/zonas');
    return json.map((e) => Zona.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// `GET /transportista/zonas`: ids de las zonas elegidas.
  Future<Set<String>> mias() async {
    final json = await _api.get<Map<String, dynamic>>('/transportista/zonas');
    return (json['zona_ids'] as List<dynamic>).cast<String>().toSet();
  }

  /// `PUT /transportista/zonas`: reemplaza las zonas elegidas por [ids].
  Future<Set<String>> guardar(Set<String> ids) async {
    final json = await _api.put<Map<String, dynamic>>(
      '/transportista/zonas',
      body: {'zona_ids': ids.toList()},
    );
    return (json['zona_ids'] as List<dynamic>).cast<String>().toSet();
  }
}
