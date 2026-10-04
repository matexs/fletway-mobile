import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/network/api_client.dart';

/// Recorrido de una solicitud para dibujarlo (`GET /solicitudes/{id}/ruta`,
/// D-35 del backend): extremos, distancia y tiempo de manejo de ida.
class RutaSolicitud {
  /// Crea la ruta.
  const RutaSolicitud({
    required this.origen,
    required this.destino,
    required this.distanciaKm,
    required this.duracionMin,
    required this.trazado,
  });

  /// Construye la ruta desde el JSON de la API.
  factory RutaSolicitud.fromJson(Map<String, dynamic> json) {
    LatLng punto(Object? p) {
      final m = p! as Map<String, dynamic>;
      return LatLng((m['lat'] as num).toDouble(), (m['lng'] as num).toDouble());
    }

    return RutaSolicitud(
      origen: punto(json['origen']),
      destino: punto(json['destino']),
      distanciaKm: (json['distancia_km'] as num).toDouble(),
      duracionMin: json['duracion_min'] as int,
      trazado: [for (final p in json['trazado'] as List<dynamic>) punto(p)],
    );
  }

  /// Dónde se carga.
  final LatLng origen;

  /// Dónde se descarga.
  final LatLng destino;

  /// Distancia por calles, de ida.
  final double distanciaKm;

  /// Tiempo de manejo de ida, en minutos.
  final int duracionMin;

  /// Puntos del recorrido, de origen a destino.
  final List<LatLng> trazado;
}

/// Repositorio de rutas. Depende de [apiClientProvider].
final rutaRepositoryProvider = Provider<RutaRepository>(
  (ref) => RutaRepository(ref.watch(apiClientProvider)),
);

/// Recorridos de solicitudes. Lanza `ApiException`.
class RutaRepository {
  /// Crea el repositorio sobre [ApiClient].
  RutaRepository(this._api);

  final ApiClient _api;

  /// `GET /solicitudes/{id}/ruta`.
  Future<RutaSolicitud> deSolicitud(String solicitudId) async {
    final json =
        await _api.get<Map<String, dynamic>>('/solicitudes/$solicitudId/ruta');
    return RutaSolicitud.fromJson(json);
  }
}

/// Ruta de la solicitud de id dado. Depende de [rutaRepositoryProvider].
/// Sin reintentos automáticos: si falla, el mapa ofrece "Reintentar".
final rutaSolicitudProvider =
    FutureProvider.autoDispose.family<RutaSolicitud, String>(
  (ref, id) => ref.watch(rutaRepositoryProvider).deSolicitud(id),
  retry: (_, __) => null,
);
