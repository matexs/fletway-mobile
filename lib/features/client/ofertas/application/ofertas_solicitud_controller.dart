import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../solicitudes/application/solicitudes_controller.dart';
import '../data/oferta_cliente_dto.dart';
import '../data/ofertas_cliente_repository.dart';

/// Ofertas de una solicitud del Cliente. Depende de
/// [ofertasClienteRepositoryProvider].
final ofertasSolicitudProvider = AsyncNotifierProvider.autoDispose
    .family<OfertasSolicitudController, OfertasDeSolicitud, String>(
  OfertasSolicitudController.new,
);

/// Muestra el top 3 por score (RN-05), suma páginas con "ver más" y acepta una
/// oferta (RF-07).
class OfertasSolicitudController extends AsyncNotifier<OfertasDeSolicitud> {
  /// Crea el controller de la solicitud [solicitudId].
  OfertasSolicitudController(this.solicitudId);

  /// Solicitud cuyas ofertas se muestran.
  final String solicitudId;

  @override
  Future<OfertasDeSolicitud> build() =>
      ref.read(ofertasClienteRepositoryProvider).ofertas(solicitudId);

  /// Vuelve al top 3 actualizado.
  Future<void> recargar() async {
    ref.invalidateSelf();
    await future;
  }

  /// Agrega la siguiente página a la lista. Devuelve el error, o null si salió
  /// bien. Efecto: red.
  Future<Failure?> verMas() async {
    final actual = state.value;
    final cursor = actual?.siguienteCursor;
    if (actual == null || cursor == null) return null;
    try {
      final pagina = await ref
          .read(ofertasClienteRepositoryProvider)
          .ofertas(solicitudId, cursor: cursor);
      state = AsyncData(pagina.copyWith(
        ofertas: [...actual.ofertas, ...pagina.ofertas],
      ));
      return null;
    } catch (e) {
      return Failure.from(e);
    }
  }

  /// Acepta la oferta [ofertaId]: crea el viaje. Devuelve el viaje y null, o
  /// null y el error. Efectos: red y recarga de la solicitud y de la lista de
  /// solicitudes (la solicitud pasa a asignada).
  Future<(ViajeConfirmado?, Failure?)> aceptar(String ofertaId) async {
    try {
      final viaje =
          await ref.read(ofertasClienteRepositoryProvider).aceptar(ofertaId);
      ref.invalidate(detalleSolicitudProvider(solicitudId));
      ref.invalidate(misSolicitudesProvider);
      return (viaje, null);
    } catch (e) {
      // Si la oferta ya no está, la lista quedó vieja: se vuelve a pedir.
      ref.invalidateSelf();
      return (null, Failure.from(e));
    }
  }
}
