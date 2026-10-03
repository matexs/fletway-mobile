import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/failure.dart';
import '../data/disponibilidad_repository.dart';

/// Estado del cambio de disponibilidad (en curso, error o listo). Depende de
/// [disponibilidadRepositoryProvider] y actualiza [authControllerProvider].
final disponibilidadControllerProvider =
    AsyncNotifierProvider.autoDispose<DisponibilidadController, void>(
  DisponibilidadController.new,
);

/// Prende o apaga la disponibilidad del Transportista (D-21): sin ella no ve
/// solicitudes nuevas.
class DisponibilidadController extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Cambia la disponibilidad y deja el perfil nuevo en la sesión. El error
  /// queda en el estado como `AsyncError` con un [Failure]. Efecto: red.
  Future<void> cambiar({required bool disponible}) async {
    state = const AsyncLoading();
    try {
      final me = await ref
          .read(disponibilidadRepositoryProvider)
          .cambiar(disponible: disponible);
      ref.read(authControllerProvider.notifier).aplicarPerfil(me);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(Failure.from(e), st);
    }
  }
}
