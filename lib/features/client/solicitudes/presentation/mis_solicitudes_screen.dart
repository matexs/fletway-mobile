import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/fechas.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/solicitudes_controller.dart';
import '../data/solicitud_dto.dart';
import 'widgets/estado_solicitud.dart';

/// Inicio del Cliente: sus solicitudes (RF-06) y el acceso a publicar una nueva.
class MisSolicitudesScreen extends ConsumerWidget {
  /// Crea la pantalla.
  const MisSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudes = ref.watch(misSolicitudesProvider);
    final controller = ref.read(misSolicitudesProvider.notifier);
    void publicar() => context.push('/cliente/solicitudes/nueva');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: ref.read(authControllerProvider.notifier).signOut,
          ),
        ],
      ),
      body: solicitudes.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: controller.recargar,
        ),
        data: (lista) => lista.isEmpty
            ? FletwayEmptyView(
                mensaje: 'Todavía no publicaste ningún traslado. Contanos qué '
                    'tenés que llevar y los transportistas te van a ofertar.',
                icono: Icons.local_shipping_outlined,
                accion: FletwayButton(
                  texto: 'Publicar solicitud',
                  icono: Icons.add,
                  onPressed: publicar,
                ),
              )
            : RefreshIndicator(
                onRefresh: controller.recargar,
                child: ListView(
                  padding: const EdgeInsets.all(FletwaySpacing.lg),
                  children: [
                    FletwayButton(
                      texto: 'Publicar solicitud',
                      icono: Icons.add,
                      anchoCompleto: true,
                      onPressed: publicar,
                    ),
                    for (final s in lista) ...[
                      const SizedBox(height: FletwaySpacing.md),
                      _SolicitudCard(
                        solicitud: s,
                        onTap: () =>
                            context.push('/cliente/solicitudes/${s.id}'),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  const _SolicitudCard({required this.solicitud, required this.onTap});

  final SolicitudResumen solicitud;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final s = solicitud;
    final estilo = estiloEstadoSolicitud(context, s.estado);
    final franja = s.franjaHorariaInicio == null
        ? 'lo antes posible'
        : 'de ${s.franjaHorariaInicio} a ${s.franjaHorariaFin}';
    return FletwayCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(estilo.icono, color: estilo.color),
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
                  '${s.cantidadObjetos == 1 ? 'objeto' : 'objetos'}',
                  style: tema.textTheme.bodySmall,
                ),
                const SizedBox(height: FletwaySpacing.xs),
                EstadoSolicitudChip(estado: s.estado),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
