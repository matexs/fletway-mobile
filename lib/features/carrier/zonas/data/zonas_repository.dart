import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

/// Zona del catálogo (`GET /zonas`).
@immutable
class Zona {
  /// Crea la zona.
  const Zona({required this.id, required this.nombre, required this.provincia});

  /// Construye la zona desde el JSON de la API.
  factory Zona.fromJson(Map<String, dynamic> json) => Zona(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        provincia: json['provincia'] as String,
      );

  /// Id de la zona.
  final String id;

  /// Partido o localidad.
  final String nombre;

  /// Provincia (o CABA).
  final String provincia;
}

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
