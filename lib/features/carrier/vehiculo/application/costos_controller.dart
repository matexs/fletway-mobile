import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../data/vehiculo_dto.dart';
import '../data/vehiculo_repository.dart';
import 'vehiculos_controller.dart';

/// Costos del vehículo de id dado; null si todavía no se cargaron. Depende de
/// [vehiculoRepositoryProvider].
final costosControllerProvider = AsyncNotifierProvider.autoDispose
    .family<CostosController, CostosVehiculo?, String>(CostosController.new);

/// Lee y guarda los costos operativos de un vehículo (RN-01).
class CostosController extends AsyncNotifier<CostosVehiculo?> {
  /// Crea el controller del vehículo [vehiculoId].
  CostosController(this.vehiculoId);

  /// Vehículo cuyos costos se editan.
  final String vehiculoId;

  @override
  Future<CostosVehiculo?> build() =>
      ref.read(vehiculoRepositoryProvider).costos(vehiculoId);

  /// Crea o reemplaza los costos. Devuelve el error, o null si salió bien.
  /// Efectos: red y recarga de [vehiculosControllerProvider] (cambia
  /// `tiene_costos`).
  Future<Failure?> guardar(CostosVehiculo costos) async {
    try {
      final guardados = await ref
          .read(vehiculoRepositoryProvider)
          .guardarCostos(vehiculoId, costos);
      state = AsyncData(guardados);
      ref.invalidate(vehiculosControllerProvider);
      return null;
    } catch (e) {
      return Failure.from(e);
    }
  }
}
