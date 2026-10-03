import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import 'objeto_dto.dart';

/// Repositorio del catálogo de objetos. Depende de [apiClientProvider].
final catalogoRepositoryProvider = Provider<CatalogoRepository>(
  (ref) => CatalogoRepository(ref.watch(apiClientProvider)),
);

/// Catálogo de objetos comunes (RN-08).
class CatalogoRepository {
  /// Crea el repositorio sobre [ApiClient].
  CatalogoRepository(this._api);

  final ApiClient _api;

  /// `GET /catalogo/objetos`, ordenado por nombre. Lanza `ApiException`.
  Future<List<ObjetoCatalogo>> objetos() async {
    final json = await _api.get<List<dynamic>>('/catalogo/objetos');
    return json
        .map((e) => ObjetoCatalogo.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
