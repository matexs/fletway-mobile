import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/solicitud.dart';
import '../data/solicitud_compatible_dto.dart';
import '../data/solicitudes_compatibles_repository.dart';

/// Solicitudes compatibles con el Transportista logueado. Depende de
/// [solicitudesCompatiblesRepositoryProvider].
final solicitudesCompatiblesProvider = AsyncNotifierProvider.autoDispose<
    SolicitudesCompatiblesController,
    List<SolicitudCompatible>>(SolicitudesCompatiblesController.new);

/// Lista lo que el Transportista puede ofertar; el filtro lo hace el backend
/// (D-21), la app no reimplementa el matching.
class SolicitudesCompatiblesController
    extends AsyncNotifier<List<SolicitudCompatible>> {
  @override
  Future<List<SolicitudCompatible>> build() =>
      ref.read(solicitudesCompatiblesRepositoryProvider).compatibles();

  /// Vuelve a pedir la lista.
  Future<void> recargar() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Detalle de una solicitud compatible. Depende de
/// [solicitudesCompatiblesRepositoryProvider].
final detalleCompatibleProvider =
    FutureProvider.autoDispose.family<Solicitud, String>(
  (ref, id) => ref.watch(solicitudesCompatiblesRepositoryProvider).detalle(id),
);
