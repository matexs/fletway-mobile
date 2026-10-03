import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/design_system/design_system.dart';
import '../../../shared/widgets/widgets.dart';

/// Pantalla de transición con sesión iniciada: muestra la carga del perfil
/// (`GET /me`) o, si falló, el error con "Reintentar" y "Cerrar sesión". Cuando
/// el perfil llega, el router lleva al inicio del rol.
class InicioScreen extends ConsumerWidget {
  /// Crea la pantalla de inicio.
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: switch (auth.estado) {
          AuthEstado.error => Padding(
              padding: const EdgeInsets.all(FletwaySpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FletwayErrorView(
                    mensaje:
                        auth.falla?.message ?? 'No pudimos cargar tu cuenta.',
                    // Una cuenta de Administrador no se arregla reintentando.
                    onReintentar: auth.falla?.code == 'rol_sin_app'
                        ? null
                        : controller.cargarPerfil,
                  ),
                  const SizedBox(height: FletwaySpacing.lg),
                  FletwayButton(
                    texto: 'Cerrar sesión',
                    variante: FletwayButtonVariante.secundario,
                    onPressed: controller.signOut,
                  ),
                ],
              ),
            ),
          _ => const FletwayLoading(mensaje: 'Cargando tu cuenta...'),
        },
      ),
    );
  }
}
