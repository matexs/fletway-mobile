import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/extensions/numeros.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../application/ofertas_solicitud_controller.dart';
import '../../data/oferta_cliente_dto.dart';
import 'oferta_card.dart';

/// Ofertas recibidas para una solicitud publicada (RF-07): el top 3 por score
/// (RN-05), "ver más" y la elección, que confirma antes de crear el viaje.
class OfertasSeccion extends ConsumerStatefulWidget {
  /// Crea la sección de la solicitud [solicitudId].
  const OfertasSeccion({required this.solicitudId, super.key});

  /// Solicitud cuyas ofertas se muestran.
  final String solicitudId;

  @override
  ConsumerState<OfertasSeccion> createState() => _OfertasSeccionState();
}

class _OfertasSeccionState extends ConsumerState<OfertasSeccion> {
  bool _cargandoMas = false;
  bool _eligiendo = false;

  void _avisar(String texto) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _verMas() async {
    setState(() => _cargandoMas = true);
    final falla = await ref
        .read(ofertasSolicitudProvider(widget.solicitudId).notifier)
        .verMas();
    if (!mounted) return;
    setState(() => _cargandoMas = false);
    if (falla != null) _avisar(falla.message);
  }

  Future<void> _elegir(OfertaParaCliente o) async {
    final ok = await confirmarFletway(
      context,
      titulo: '¿Elegir a ${o.transportistaNombre}?',
      mensaje: 'Confirmás el viaje por ${o.precioCalculado.pesos}. Las demás '
          'ofertas se descartan y vas a ver la patente del vehículo.',
      textoConfirmar: 'Confirmar viaje',
      icono: Icons.handshake_outlined,
    );
    if (!ok || !mounted) return;
    setState(() => _eligiendo = true);
    final (viaje, falla) = await ref
        .read(ofertasSolicitudProvider(widget.solicitudId).notifier)
        .aceptar(o.id);
    if (!mounted) return;
    setState(() => _eligiendo = false);
    if (falla != null) {
      _avisar(falla.message);
      return;
    }
    await context.push('/cliente/viajes/${viaje!.id}/confirmado', extra: viaje);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ofertasSolicitudProvider(widget.solicitudId);
    final ofertas = ref.watch(provider);
    return ofertas.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(FletwaySpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => FletwayErrorView(
        mensaje: Failure.from(e).message,
        onReintentar: () => ref.invalidate(provider),
      ),
      data: (d) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FletwaySeccion(
            icono: Icons.request_quote_outlined,
            titulo: d.total == 0 ? 'Ofertas' : 'Ofertas (${d.total})',
            detalle: d.total == 0
                ? null
                : 'Ordenadas por precio, calificación y cumplimiento.',
          ),
          if (d.total == 0)
            FletwayEmptyView(
              mensaje: 'Todavía no recibiste ofertas. Les avisamos a los '
                  'transportistas de la zona; volvé a mirar en un rato.',
              icono: Icons.hourglass_empty,
              accion: FletwayButton(
                texto: 'Actualizar',
                icono: Icons.refresh,
                variante: FletwayButtonVariante.secundario,
                onPressed: ref.read(provider.notifier).recargar,
              ),
            ),
          for (final (i, o) in d.ofertas.indexed) ...[
            const SizedBox(height: FletwaySpacing.md),
            OfertaCard(
              oferta: o,
              ayudantesPedidos: d.cantidadAyudantesSolicitados,
              recomendada: i == 0,
              onPerfil: () =>
                  context.push('/cliente/transportistas/${o.transportistaId}'),
              onElegir: _eligiendo ? null : () => _elegir(o),
            ),
          ],
          if (d.siguienteCursor != null) ...[
            const SizedBox(height: FletwaySpacing.md),
            FletwayButton(
              texto: 'Ver más ofertas (${d.total - d.ofertas.length})',
              icono: Icons.expand_more,
              variante: FletwayButtonVariante.secundario,
              cargando: _cargandoMas,
              onPressed: _verMas,
            ),
          ],
        ],
      ),
    );
  }
}
