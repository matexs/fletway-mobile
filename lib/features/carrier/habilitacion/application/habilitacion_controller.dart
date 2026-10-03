import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/app_user.dart';
import '../../../../core/auth/auth_controller.dart';
import '../data/habilitacion_dto.dart';
import '../data/habilitacion_repository.dart';

/// Estado de habilitación y documentos del Transportista logueado. Depende de
/// [habilitacionRepositoryProvider] y mantiene al día el estado del
/// [authControllerProvider], que usan los guards del router.
final habilitacionControllerProvider =
    AsyncNotifierProvider.autoDispose<HabilitacionController, MiHabilitacion>(
  HabilitacionController.new,
);

/// Lee la documentación del Transportista (RF-16, RF-01). La revisión la hace el
/// Administrador por fuera de la app, así que la pantalla recarga a pedido.
class HabilitacionController extends AsyncNotifier<MiHabilitacion> {
  @override
  Future<MiHabilitacion> build() async {
    final mi = await ref.read(habilitacionRepositoryProvider).obtener();
    // El rol y el estado vienen de /me al loguearse; si el Administrador revisó
    // después, se actualizan acá.
    ref.read(authControllerProvider.notifier).actualizarEstadoHabilitacion(
          AppUser.estadoDesdeCodigo(mi.estadoHabilitacion),
        );
    return mi;
  }

  /// Vuelve a pedir el estado al backend, conservando el valor anterior mientras
  /// carga (para el pull-to-refresh).
  Future<void> recargar() async {
    ref.invalidateSelf();
    await future;
  }
}
