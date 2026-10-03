import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/fechas.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/mis_ofertas_controller.dart';
import '../data/oferta_dto.dart';
import 'widgets/desglose_oferta_view.dart';
import 'widgets/estado_oferta.dart';

/// Ofertas del Transportista (RF-17): estado, precio y desglose; las
/// pendientes se pueden retirar (D-23).
class MisOfertasScreen extends ConsumerWidget {
  /// Crea la pantalla.
  const MisOfertasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ofertas = ref.watch(misOfertasProvider);
    final controller = ref.read(misOfertasProvider.notifier);

    Future<void> retirar(Oferta o) async {
      final confirmado = await confirmarFletway(
        context,
        titulo: 'Retirar la oferta',
        mensaje: 'El Cliente deja de verla. Podés volver a ofertar mientras '
            'la solicitud siga publicada.',
        textoConfirmar: 'Retirar',
        icono: Icons.undo,
      );
      if (!confirmado) return;
      final error = await controller.retirar(o.id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis ofertas')),
      body: ofertas.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: controller.recargar,
        ),
        data: (lista) => lista.isEmpty
            ? FletwayEmptyView(
                mensaje: 'Todavía no ofertaste. Mirá las solicitudes de tus '
                    'zonas y armá tu primera oferta.',
                icono: Icons.request_quote_outlined,
                accion: FletwayButton(
                  texto: 'Ver solicitudes',
                  icono: Icons.campaign_outlined,
                  onPressed: () => context.push('/transportista/solicitudes'),
                ),
              )
            : RefreshIndicator(
                onRefresh: controller.recargar,
                child: ListView(
                  padding: const EdgeInsets.all(FletwaySpacing.lg),
                  children: [
                    for (final o in lista) ...[
                      _OfertaCard(
                        oferta: o,
                        onRetirar:
                            o.estado == 'pendiente' ? () => retirar(o) : null,
                      ),
                      const SizedBox(height: FletwaySpacing.md),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _OfertaCard extends StatelessWidget {
  const _OfertaCard({required this.oferta, this.onRetirar});

  final Oferta oferta;
  final VoidCallback? onRetirar;

  @override
  Widget build(BuildContext context) {
    final o = oferta;
    final tema = Theme.of(context);
    return FletwayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${o.origenZonaNombre} → ${o.destinoZonaNombre}',
              style: tema.textTheme.titleMedium),
          const SizedBox(height: FletwaySpacing.xs),
          EstadoOfertaChip(estado: o.estado),
          const SizedBox(height: FletwaySpacing.xs),
          _Dato(
            icono: Icons.event_outlined,
            texto: fechaDesdeApi(o.fechaServicioDeseada).larga +
                (o.solicitudEstado == 'vencida'
                    ? ' · la solicitud venció'
                    : o.solicitudEstado == 'cancelada'
                        ? ' · el Cliente la canceló'
                        : ''),
          ),
          _Dato(
            icono: Icons.local_shipping_outlined,
            texto: '${o.vehiculoTipo} · ${o.vehiculoPatente}',
          ),
          _Dato(
            icono: Icons.groups_outlined,
            texto: '${o.cantidadViajes} '
                '${o.cantidadViajes == 1 ? 'viaje' : 'viajes'} · '
                '${o.cantidadAyudantes} '
                '${o.cantidadAyudantes == 1 ? 'ayudante' : 'ayudantes'}',
          ),
          const SizedBox(height: FletwaySpacing.sm),
          Text(o.precioCalculado.pesos, style: tema.textTheme.headlineSmall),
          DesgloseOfertaView(desglose: o.desglose),
          if (onRetirar != null)
            Align(
              alignment: Alignment.centerRight,
              child: FletwayButton(
                texto: 'Retirar',
                icono: Icons.undo,
                variante: FletwayButtonVariante.secundario,
                onPressed: onRetirar,
              ),
            ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: FletwaySpacing.xs),
      child: Row(
        children: [
          Icon(icono,
              size: FletwaySpacing.lg,
              color: tema.colorScheme.onSurfaceVariant),
          const SizedBox(width: FletwaySpacing.sm),
          Expanded(child: Text(texto, style: tema.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
