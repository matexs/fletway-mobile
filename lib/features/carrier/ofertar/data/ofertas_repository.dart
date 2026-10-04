import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import 'oferta_dto.dart';

/// Repositorio de ofertas del Transportista. Depende de [apiClientProvider].
final ofertasRepositoryProvider = Provider<OfertasRepository>(
  (ref) => OfertasRepository(ref.watch(apiClientProvider)),
);

/// Ofertas del Transportista (RF-17). El precio y los viajes los calcula el
/// backend (RN-01, RN-02). Lanza `ApiException`.
class OfertasRepository {
  /// Crea el repositorio sobre [ApiClient].
  OfertasRepository(this._api);

  final ApiClient _api;

  Map<String, dynamic> _pedido(String vehiculoId, int ayudantes) =>
      {'vehiculo_id': vehiculoId, 'cantidad_ayudantes': ayudantes};

  /// `POST /solicitudes/{id}/ofertas/cotizar`: precio y viajes sin guardar.
  Future<Cotizacion> cotizar(
    String solicitudId, {
    required String vehiculoId,
    required int ayudantes,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/solicitudes/$solicitudId/ofertas/cotizar',
      body: _pedido(vehiculoId, ayudantes),
    );
    return Cotizacion.fromJson(json);
  }

  /// `POST /solicitudes/{id}/ofertas`: calcula y guarda la oferta.
  Future<Oferta> ofertar(
    String solicitudId, {
    required String vehiculoId,
    required int ayudantes,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/solicitudes/$solicitudId/ofertas',
      body: _pedido(vehiculoId, ayudantes),
    );
    return Oferta.fromJson(json);
  }

  /// `POST /ofertas/{id}/retirar`.
  Future<Oferta> retirar(String ofertaId) async {
    final json =
        await _api.post<Map<String, dynamic>>('/ofertas/$ofertaId/retirar');
    return Oferta.fromJson(json);
  }

  /// `GET /transportista/ofertas`, las más nuevas primero.
  Future<List<Oferta>> propias() async {
    final json = await _api.get<List<dynamic>>('/transportista/ofertas');
    return json.map((e) => Oferta.fromJson(e as Map<String, dynamic>)).toList();
  }
}
