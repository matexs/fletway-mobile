import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/vehiculos_controller.dart';
import 'widgets/vehiculo_card.dart';

/// Vehículos del Transportista: listado, alta y activar o desactivar (RF-18).
class VehiculosScreen extends ConsumerWidget {
  /// Crea la pantalla.
  const VehiculosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculos = ref.watch(vehiculosControllerProvider);
    final controller = ref.read(vehiculosControllerProvider.notifier);

    Future<void> cambiarActivo(String id, bool activo) async {
      final falla = await controller.cambiarActivo(id, activo: activo);
      if (falla != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(falla.message)));
      }
    }

    void agregar() => context.push('/transportista/vehiculos/nuevo');

    return Scaffold(
      appBar: AppBar(title: const Text('Mis vehículos')),
      body: vehiculos.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: controller.recargar,
        ),
        data: (lista) => lista.isEmpty
            ? FletwayEmptyView(
                mensaje:
                    'Todavía no cargaste vehículos. Necesitás al menos uno '
                    'para ofertar.',
                icono: Icons.local_shipping_outlined,
                accion: FletwayButton(
                  texto: 'Agregar vehículo',
                  icono: Icons.add,
                  onPressed: agregar,
                ),
              )
            : RefreshIndicator(
                onRefresh: controller.recargar,
                child: ListView(
                  padding: const EdgeInsets.all(FletwaySpacing.lg),
                  children: [
                    FletwayButton(
                      texto: 'Agregar vehículo',
                      icono: Icons.add,
                      anchoCompleto: true,
                      onPressed: agregar,
                    ),
                    for (final v in lista) ...[
                      const SizedBox(height: FletwaySpacing.md),
                      VehiculoCard(
                        vehiculo: v,
                        onActivo: (activo) => cambiarActivo(v.id, activo),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
