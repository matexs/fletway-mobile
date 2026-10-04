import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../data/vehiculo_dto.dart';
import '../data/vehiculo_repository.dart';
import 'vehiculos_controller.dart';

/// Estado del envío del alta de un vehículo: el valor es el vehículo creado.
/// Depende de [vehiculoRepositoryProvider].
final altaVehiculoControllerProvider =
    AsyncNotifierProvider.autoDispose<AltaVehiculoController, Vehiculo?>(
  AltaVehiculoController.new,
);

/// Registra un vehículo (RF-18). Los costos son de referencia por tipo (D-34).
class AltaVehiculoController extends AsyncNotifier<Vehiculo?> {
  @override
  Vehiculo? build() => null;

  /// Crea el vehículo. El error queda en el estado como `AsyncError` con un
  /// [Failure]. Efectos: red y recarga de [vehiculosControllerProvider].
  Future<void> crear(NuevoVehiculo nuevo) async {
    state = const AsyncLoading();
    try {
      final v = await ref.read(vehiculoRepositoryProvider).crear(nuevo);
      ref.invalidate(vehiculosControllerProvider);
      state = AsyncData(v);
    } catch (e, st) {
      state = AsyncError(Failure.from(e), st);
    }
  }
}
