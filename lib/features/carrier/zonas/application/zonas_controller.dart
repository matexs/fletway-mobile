import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../data/zonas_repository.dart';

/// Catálogo de zonas y las elegidas por el Transportista.
@immutable
class ZonasDeTrabajo {
  /// Crea el estado.
  const ZonasDeTrabajo({required this.catalogo, required this.elegidas});

  /// Todas las zonas, ordenadas por provincia y nombre.
  final List<Zona> catalogo;

  /// Ids de las zonas de trabajo guardadas.
  final Set<String> elegidas;
}

/// Zonas de trabajo del Transportista logueado. Depende de
/// [zonasRepositoryProvider].
final zonasControllerProvider =
    AsyncNotifierProvider.autoDispose<ZonasController, ZonasDeTrabajo>(
  ZonasController.new,
);

/// Lee y guarda las zonas de trabajo (RN-04): el Transportista ve las
/// solicitudes con origen o destino en ellas.
class ZonasController extends AsyncNotifier<ZonasDeTrabajo> {
  @override
  Future<ZonasDeTrabajo> build() async {
    final repo = ref.read(zonasRepositoryProvider);
    final (catalogo, elegidas) = await (repo.catalogo(), repo.mias()).wait;
    return ZonasDeTrabajo(catalogo: catalogo, elegidas: elegidas);
  }

  /// Guarda [ids] como zonas de trabajo. Devuelve el error, o null si salió
  /// bien. Efecto: red.
  Future<Failure?> guardar(Set<String> ids) async {
    try {
      final elegidas = await ref.read(zonasRepositoryProvider).guardar(ids);
      final actual = state.value;
      if (actual != null) {
        state = AsyncData(
          ZonasDeTrabajo(catalogo: actual.catalogo, elegidas: elegidas),
        );
      }
      return null;
    } catch (e) {
      return Failure.from(e);
    }
  }
}
