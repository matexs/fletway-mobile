import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/models/me.dart';

/// Repositorio de la disponibilidad del Transportista. Depende de
/// [apiClientProvider].
final disponibilidadRepositoryProvider = Provider<DisponibilidadRepository>(
  (ref) => DisponibilidadRepository(ref.watch(apiClientProvider)),
);

/// Interruptor "estoy tomando trabajos" (D-21).
class DisponibilidadRepository {
  /// Crea el repositorio sobre [ApiClient].
  DisponibilidadRepository(this._api);

  final ApiClient _api;

  /// `PUT /transportista/disponibilidad`. Devuelve el perfil actualizado. Lanza
  /// `ApiException`.
  Future<Me> cambiar({required bool disponible}) async {
    final json = await _api.put<Map<String, dynamic>>(
      '/transportista/disponibilidad',
      body: {'disponible': disponible},
    );
    return Me.fromJson(json);
  }
}
