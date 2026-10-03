import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/disponibilidad_controller.dart';

/// Inicio del Transportista habilitado: interruptor de disponibilidad (D-21) y
/// accesos a sus vehículos (RF-18), zonas (RN-04) y documentación (RF-01). Las
/// solicitudes compatibles se suman en el módulo 7.
class InicioTransportistaScreen extends ConsumerWidget {
  /// Crea la pantalla.
  const InicioTransportistaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(disponibilidadControllerProvider, (_, siguiente) {
      if (siguiente case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Failure.from(error).message)),
        );
      }
    });
    final user = ref.watch(authControllerProvider).user;
    final cambiando = ref.watch(disponibilidadControllerProvider).isLoading;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: ref.read(authControllerProvider.notifier).signOut,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(FletwaySpacing.lg),
        children: [
          if (user != null)
            Text(
              'Hola, ${user.nombreCompleto.split(' ').first}',
              style: tema.textTheme.headlineSmall,
            ),
          const SizedBox(height: FletwaySpacing.lg),
          FletwayCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Estoy tomando trabajos'),
              subtitle: Text(
                user?.disponible == true
                    ? 'Te avisamos de las solicitudes nuevas de tus zonas.'
                    : 'No te llegan solicitudes nuevas.',
              ),
              value: user?.disponible ?? false,
              onChanged: cambiando
                  ? null
                  : (v) => ref
                      .read(disponibilidadControllerProvider.notifier)
                      .cambiar(disponible: v),
            ),
          ),
          for (final (icono, titulo, detalle, ruta) in const [
            (
              Icons.local_shipping_outlined,
              'Mis vehículos',
              'Medidas, carga útil y costos.',
              '/transportista/vehiculos',
            ),
            (
              Icons.map_outlined,
              'Zonas de trabajo',
              'Dónde tomás trabajos.',
              '/transportista/zonas',
            ),
            (
              Icons.badge_outlined,
              'Mi documentación',
              'DNI, registro, seguro y VTV.',
              '/transportista/habilitacion',
            ),
          ]) ...[
            const SizedBox(height: FletwaySpacing.md),
            FletwayCard(
              onTap: () => context.push(ruta),
              child: Row(
                children: [
                  Icon(icono, color: tema.colorScheme.primary),
                  const SizedBox(width: FletwaySpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titulo, style: tema.textTheme.titleMedium),
                        Text(detalle, style: tema.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
