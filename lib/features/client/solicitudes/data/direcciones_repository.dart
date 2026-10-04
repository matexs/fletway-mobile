import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

/// Dirección propuesta mientras el Cliente escribe (D-35 del backend).
class SugerenciaDireccion {
  /// Crea la sugerencia.
  const SugerenciaDireccion({required this.direccion, required this.detalle});

  /// Construye la sugerencia desde el JSON de la API.
  factory SugerenciaDireccion.fromJson(Map<String, dynamic> json) =>
      SugerenciaDireccion(
        direccion: json['direccion'] as String,
        detalle: json['detalle'] as String? ?? '',
      );

  /// Calle y altura, lo que se guarda en la solicitud.
  final String direccion;

  /// Localidad y código postal, para distinguirla de otras.
  final String detalle;
}

/// Repositorio del autocompletado. Depende de [apiClientProvider].
final direccionesRepositoryProvider = Provider<DireccionesRepository>(
  (ref) => DireccionesRepository(ref.watch(apiClientProvider)),
);

/// Sugerencias de direcciones dentro de una zona. Lanza `ApiException`.
class DireccionesRepository {
  /// Crea el repositorio sobre [ApiClient].
  DireccionesRepository(this._api);

  final ApiClient _api;

  /// `GET /direcciones/sugerencias?zona_id=&q=`. [texto] tiene que tener al
  /// menos 3 caracteres.
  Future<List<SugerenciaDireccion>> sugerencias(
      String zonaId, String texto) async {
    final json = await _api.get<List<dynamic>>(
      '/direcciones/sugerencias',
      query: {'zona_id': zonaId, 'q': texto},
    );
    return [
      for (final e in json)
        SugerenciaDireccion.fromJson(e as Map<String, dynamic>),
    ];
  }
}
