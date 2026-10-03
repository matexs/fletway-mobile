import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/models/solicitud.dart';
import '../../../../shared/models/zona.dart';
import '../data/solicitud_dto.dart';
import '../data/solicitudes_repository.dart';

/// Zonas para elegir origen y destino. Depende de
/// [solicitudesRepositoryProvider].
final zonasSolicitudProvider = FutureProvider.autoDispose<List<Zona>>(
  (ref) => ref.watch(solicitudesRepositoryProvider).zonas(),
);

/// Solicitudes del Cliente logueado. Depende de
/// [solicitudesRepositoryProvider].
final misSolicitudesProvider = AsyncNotifierProvider.autoDispose<
    MisSolicitudesController,
    List<SolicitudResumen>>(MisSolicitudesController.new);

/// Lista las solicitudes propias, con el vencimiento ya calculado por el
/// backend (D-20).
class MisSolicitudesController extends AsyncNotifier<List<SolicitudResumen>> {
  @override
  Future<List<SolicitudResumen>> build() =>
      ref.read(solicitudesRepositoryProvider).propias();

  /// Vuelve a pedir la lista.
  Future<void> recargar() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Estado del envío de una solicitud nueva: el valor es la publicada. Depende de
/// [solicitudesRepositoryProvider].
final publicarSolicitudProvider =
    AsyncNotifierProvider.autoDispose<PublicarSolicitudController, Solicitud?>(
  PublicarSolicitudController.new,
);

/// Publica una solicitud (RF-06). No hay cotización: los precios llegan con las
/// ofertas (RN-01).
class PublicarSolicitudController extends AsyncNotifier<Solicitud?> {
  @override
  Solicitud? build() => null;

  /// Publica [nueva]. El error queda en el estado como `AsyncError` con un
  /// [Failure]. Efectos: red y recarga de [misSolicitudesProvider].
  Future<void> publicar(NuevaSolicitud nueva) async {
    state = const AsyncLoading();
    try {
      final s = await ref.read(solicitudesRepositoryProvider).publicar(nueva);
      ref.invalidate(misSolicitudesProvider);
      state = AsyncData(s);
    } catch (e, st) {
      state = AsyncError(Failure.from(e), st);
    }
  }
}

/// Detalle de la solicitud de id dado. Depende de
/// [solicitudesRepositoryProvider].
final detalleSolicitudProvider = AsyncNotifierProvider.autoDispose
    .family<DetalleSolicitudController, Solicitud, String>(
  DetalleSolicitudController.new,
);

/// Muestra una solicitud y permite cancelarla o republicarla (D-20).
class DetalleSolicitudController extends AsyncNotifier<Solicitud> {
  /// Crea el controller de la solicitud [solicitudId].
  DetalleSolicitudController(this.solicitudId);

  /// Solicitud que se muestra.
  final String solicitudId;

  @override
  Future<Solicitud> build() =>
      ref.read(solicitudesRepositoryProvider).detalle(solicitudId);

  /// Cancela la solicitud. Devuelve el error, o null si salió bien. Efectos:
  /// red y recarga de [misSolicitudesProvider].
  Future<Failure?> cancelar() async {
    try {
      state = AsyncData(
        await ref.read(solicitudesRepositoryProvider).cancelar(solicitudId),
      );
      ref.invalidate(misSolicitudesProvider);
      return null;
    } catch (e) {
      return Failure.from(e);
    }
  }

  /// Republica la solicitud vencida con otra fecha (`AAAA-MM-DD`). Devuelve la
  /// solicitud nueva y null, o null y el error. Efectos: red y recarga de
  /// [misSolicitudesProvider].
  Future<(Solicitud?, Failure?)> republicar(String fecha) async {
    try {
      final nueva = await ref
          .read(solicitudesRepositoryProvider)
          .republicar(solicitudId, fecha: fecha);
      ref.invalidate(misSolicitudesProvider);
      return (nueva, null);
    } catch (e) {
      return (null, Failure.from(e));
    }
  }
}
