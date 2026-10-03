import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/supabase/supabase_client.dart';
import 'habilitacion_dto.dart';
import 'selector_archivo.dart';

/// Repositorio de la documentación del Transportista. Depende de
/// [apiClientProvider] y del cliente de Supabase (Storage).
final habilitacionRepositoryProvider = Provider<HabilitacionRepository>(
  (ref) => HabilitacionRepository(
    ref.watch(apiClientProvider),
    SupabaseInit.client.storage,
  ),
);

/// Error de validación local de un archivo, antes de subirlo.
class ArchivoInvalido implements Exception {
  /// Crea el error con el [mensaje] para el usuario.
  const ArchivoInvalido(this.mensaje);

  /// Texto para el usuario.
  final String mensaje;

  @override
  String toString() => 'ArchivoInvalido($mensaje)';
}

/// Carga de documentos (RF-16): sube el archivo a Storage y lo registra en el
/// backend (D-19).
class HabilitacionRepository {
  /// Crea el repositorio sobre la API y Supabase Storage.
  HabilitacionRepository(this._api, this._storage);

  final ApiClient _api;
  final SupabaseStorageClient _storage;

  /// Bucket privado de la documentación (D-19).
  static const bucket = 'documentos-transportista';

  /// Tamaño máximo por archivo (D-19).
  static const tamanoMaximo = 10 * 1024 * 1024;

  static const _tipos = {
    'pdf': 'application/pdf',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
  };

  /// Pide `GET /transportista/documentos`. Lanza `ApiException`.
  Future<MiHabilitacion> obtener() async {
    final json = await _api.get<Map<String, dynamic>>(
      '/transportista/documentos',
    );
    return MiHabilitacion.fromJson(json);
  }

  /// Sube [archivo] a `transportista/{usuarioId}/` y lo registra como documento
  /// de [tipo] con `POST /transportista/documentos`. Lanza [ArchivoInvalido] si
  /// el formato o el tamaño no sirven (D-19), `StorageException` si falla la
  /// subida y `ApiException` si falla el registro.
  Future<Documento> cargar({
    required String usuarioId,
    required String tipo,
    required ArchivoElegido archivo,
  }) async {
    final contentType = _tipos[archivo.extension];
    if (contentType == null) {
      throw const ArchivoInvalido('El archivo tiene que ser PDF, JPG o PNG.');
    }
    if (archivo.bytes.length > tamanoMaximo) {
      throw const ArchivoInvalido('El archivo no puede superar los 10 MB.');
    }
    // Un objeto nuevo por carga: el historial de reintentos queda en la base.
    final path =
        'transportista/$usuarioId/$tipo-${DateTime.now().millisecondsSinceEpoch}.${archivo.extension}';
    await _storage.from(bucket).uploadBinary(
          path,
          archivo.bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
    final json = await _api.post<Map<String, dynamic>>(
      '/transportista/documentos',
      body: {'tipo_documento_codigo': tipo, 'path': path},
    );
    return Documento.fromJson(json);
  }
}
