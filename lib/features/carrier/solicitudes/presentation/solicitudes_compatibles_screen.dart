import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/fechas.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/solicitudes_compatibles_controller.dart';
import '../data/solicitud_compatible_dto.dart';

/// Solicitudes que el Transportista puede ofertar (RN-04, D-21): de sus zonas,
/// con capacidad en algún vehículo activo y mientras esté disponible.
class SolicitudesCompatiblesScreen extends ConsumerWidget {
  /// Crea la pantalla.
  const SolicitudesCompatiblesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudes = ref.watch(solicitudesCompatiblesProvider);
    final controller = ref.read(solicitudesCompatiblesProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes en tus zonas')),
      body: solicitudes.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: controller.recargar,
        ),
        data: (lista) => lista.isEmpty
            ? FletwayEmptyView(
                mensaje: 'No hay solicitudes para vos ahora. Revisá que estés '
                    'disponible, que tengas zonas elegidas y un vehículo '
                    'activo con capacidad.',
                icono: Icons.search_off,
                accion: FletwayButton(
                  texto: 'Actualizar',
                  icono: Icons.refresh,
                  variante: FletwayButtonVariante.secundario,
                  onPressed: controller.recargar,
                ),
              )
            : RefreshIndicator(
                onRefresh: controller.recargar,
                child: ListView.separated(
                  padding: const EdgeInsets.all(FletwaySpacing.lg),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: FletwaySpacing.md),
                  itemBuilder: (context, i) => _SolicitudCard(
                    solicitud: lista[i],
                    onTap: () => context
                        .push('/transportista/solicitudes/${lista[i].id}'),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  const _SolicitudCard({required this.solicitud, required this.onTap});

  final SolicitudCompatible solicitud;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final s = solicitud;
    final franja = s.franjaHorariaInicio == null
        ? 'lo antes posible'
        : 'de ${s.franjaHorariaInicio} a ${s.franjaHorariaFin}';
    return FletwayCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: tema.colorScheme.primary),
          const SizedBox(width: FletwaySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.origenZonaNombre} → ${s.destinoZonaNombre}',
                  style: tema.textTheme.titleMedium,
                ),
                const SizedBox(height: FletwaySpacing.xs),
                Text(
                  '${fechaDesdeApi(s.fechaServicioDeseada).larga}, $franja',
                  style: tema.textTheme.bodyMedium,
                ),
                Text(
                  '${s.cantidadObjetos} '
                  '${s.cantidadObjetos == 1 ? 'objeto' : 'objetos'} · '
                  '${s.pesoTotalKg.legible} kg · ${s.volumenTotalM3.legible} m³'
                  '${s.cantidadAyudantesSolicitados > 0 ? ' · pide ${s.cantidadAyudantesSolicitados} ayudantes' : ''}',
                  style: tema.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
