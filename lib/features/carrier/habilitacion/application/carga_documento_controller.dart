import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/failure.dart';
import '../data/habilitacion_repository.dart';
import '../data/selector_archivo.dart';
import 'habilitacion_controller.dart';

/// Estado del envío de un documento (carga en curso, error o listo). Depende de
/// [selectorArchivoProvider], [habilitacionRepositoryProvider] y
/// [authControllerProvider].
final cargaDocumentoControllerProvider =
    AsyncNotifierProvider.autoDispose<CargaDocumentoController, void>(
  CargaDocumentoController.new,
);

/// Elige un archivo, lo sube y lo registra (RF-16). Al terminar recarga la
/// habilitación: si el Transportista estaba rechazado, vuelve a pendiente
/// (D-33).
class CargaDocumentoController extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Abre el selector de [origen] y carga el archivo como documento de [tipo].
  /// Devuelve false si el usuario canceló (no cambia el estado). Los errores
  /// quedan en el estado como `AsyncError` con un [Failure]. Efectos: Storage, red y recarga de
  /// [habilitacionControllerProvider].
  Future<bool> cargar(String tipo, OrigenArchivo origen) async {
    final archivo = await ref.read(selectorArchivoProvider).elegir(origen);
    if (archivo == null) return false;

    final usuarioId = ref.read(authControllerProvider).user?.id;
    if (usuarioId == null) return false;

    state = const AsyncLoading();
    try {
      await ref
          .read(habilitacionRepositoryProvider)
          .cargar(usuarioId: usuarioId, tipo: tipo, archivo: archivo);
      state = const AsyncData(null);
      ref.invalidate(habilitacionControllerProvider);
    } on ArchivoInvalido catch (e, st) {
      state = AsyncError(Failure(e.mensaje, code: 'archivo_invalido'), st);
    } catch (e, st) {
      state = AsyncError(Failure.from(e), st);
    }
    return true;
  }
}
