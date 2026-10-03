import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../data/vehiculo_dto.dart';
import '../data/vehiculo_repository.dart';

/// Tipos de vehículo con sus medidas estándar. Depende de
/// [vehiculoRepositoryProvider].
final tiposVehiculoProvider = FutureProvider.autoDispose<List<TipoVehiculo>>(
  (ref) => ref.watch(vehiculoRepositoryProvider).tipos(),
);

/// Vehículos del Transportista logueado. Depende de
/// [vehiculoRepositoryProvider].
final vehiculosControllerProvider =
    AsyncNotifierProvider.autoDispose<VehiculosController, List<Vehiculo>>(
  VehiculosController.new,
);

/// Lista los vehículos propios y los activa o desactiva (RF-18).
class VehiculosController extends AsyncNotifier<List<Vehiculo>> {
  @override
  Future<List<Vehiculo>> build() =>
      ref.read(vehiculoRepositoryProvider).propios();

  /// Vuelve a pedir la lista.
  Future<void> recargar() async {
    ref.invalidateSelf();
    await future;
  }

  /// Activa o desactiva el vehículo [id]; un inactivo no cuenta para el
  /// matchmaking ni para ofertar (D-21). Devuelve el error, o null si salió
  /// bien. Efecto: red.
  Future<Failure?> cambiarActivo(String id, {required bool activo}) async {
    try {
      final actualizado = await ref
          .read(vehiculoRepositoryProvider)
          .cambiarActivo(id, activo: activo);
      final lista = state.value ?? const <Vehiculo>[];
      state = AsyncData([
        for (final v in lista) v.id == id ? actualizado : v,
      ]);
      return null;
    } catch (e) {
      return Failure.from(e);
    }
  }
}
