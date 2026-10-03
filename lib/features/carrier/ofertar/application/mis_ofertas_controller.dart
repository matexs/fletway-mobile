import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../data/oferta_dto.dart';
import '../data/ofertas_repository.dart';

/// Ofertas del Transportista logueado. Depende de [ofertasRepositoryProvider].
final misOfertasProvider =
    AsyncNotifierProvider.autoDispose<MisOfertasController, List<Oferta>>(
  MisOfertasController.new,
);

/// Lista las ofertas propias y las retira (D-23).
class MisOfertasController extends AsyncNotifier<List<Oferta>> {
  @override
  Future<List<Oferta>> build() => ref.read(ofertasRepositoryProvider).propias();

  /// Vuelve a pedir la lista.
  Future<void> recargar() async {
    ref.invalidateSelf();
    await future;
  }

  /// Retira la oferta [id]. Devuelve el error, o null si salió bien. Efecto:
  /// red.
  Future<Failure?> retirar(String id) async {
    try {
      final retirada = await ref.read(ofertasRepositoryProvider).retirar(id);
      final lista = state.value ?? const <Oferta>[];
      state = AsyncData([for (final o in lista) o.id == id ? retirada : o]);
      return null;
    } catch (e) {
      return Failure.from(e);
    }
  }
}
