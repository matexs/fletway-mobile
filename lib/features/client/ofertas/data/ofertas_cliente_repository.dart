import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import 'oferta_cliente_dto.dart';

/// Repositorio de las ofertas que recibe el Cliente. Depende de
/// [apiClientProvider].
final ofertasClienteRepositoryProvider = Provider<OfertasClienteRepository>(
  (ref) => OfertasClienteRepository(ref.watch(apiClientProvider)),
);

/// Ofertas de las solicitudes del Cliente y su aceptación (RF-07). Lanza
/// `ApiException`.
class OfertasClienteRepository {
  /// Crea el repositorio sobre [ApiClient].
  OfertasClienteRepository(this._api);

  final ApiClient _api;

  /// `GET /solicitudes/{id}/ofertas`: sin [cursor], el top 3; con [cursor], la
  /// página de "ver más" desde esa posición.
  Future<OfertasDeSolicitud> ofertas(String solicitudId, {int? cursor}) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/solicitudes/$solicitudId/ofertas',
      query: cursor == null ? null : {'ver_mas': 'true', 'cursor': '$cursor'},
    );
    return OfertasDeSolicitud.fromJson(json);
  }

  /// `POST /ofertas/{id}/aceptar`: crea el viaje.
  Future<ViajeConfirmado> aceptar(String ofertaId) async {
    final json =
        await _api.post<Map<String, dynamic>>('/ofertas/$ofertaId/aceptar');
    return ViajeConfirmado.fromJson(json);
  }
}
