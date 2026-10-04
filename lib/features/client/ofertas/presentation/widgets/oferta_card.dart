import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/extensions/numeros.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../data/oferta_cliente_dto.dart';
import 'reputacion.dart';

/// Una oferta para el Cliente: quién, con qué, cuántos viajes y ayudantes y el
/// precio final. Tocar el nombre abre el perfil; el botón la elige.
class OfertaCard extends StatelessWidget {
  /// Crea la card de [oferta]. [ayudantesPedidos] es lo que pidió el Cliente,
  /// para compararlo (es orientativo, D-20).
  const OfertaCard({
    required this.oferta,
    required this.ayudantesPedidos,
    required this.onPerfil,
    required this.onElegir,
    this.recomendada = false,
    super.key,
  });

  /// Oferta a mostrar.
  final OfertaParaCliente oferta;

  /// Ayudantes que pidió el Cliente.
  final int ayudantesPedidos;

  /// Abre el perfil del Transportista.
  final VoidCallback onPerfil;

  /// Elige la oferta. Null deshabilita el botón.
  final VoidCallback? onElegir;

  /// Si es la primera del score.
  final bool recomendada;

  @override
  Widget build(BuildContext context) {
    final o = oferta;
    final tema = Theme.of(context);
    final ayudantes = '${o.cantidadAyudantes} '
        '${o.cantidadAyudantes == 1 ? 'ayudante' : 'ayudantes'}';
    return FletwayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recomendada) ...[
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined,
                    size: FletwaySpacing.lg, color: tema.colorScheme.primary),
                const SizedBox(width: FletwaySpacing.xs),
                Text('Recomendada',
                    style: tema.textTheme.labelLarge
                        ?.copyWith(color: tema.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: FletwaySpacing.xs),
          ],
          InkWell(
            onTap: onPerfil,
            child: Row(
              children: [
                Expanded(
                  child: Text(o.transportistaNombre,
                      style: tema.textTheme.titleMedium),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          Reputacion(
            calificacion: o.calificacionPromedio,
            cantidadResenas: o.cantidadResenas,
            tasaCumplimiento: o.tasaCumplimiento,
          ),
          const SizedBox(height: FletwaySpacing.sm),
          Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  size: FletwaySpacing.lg,
                  color: tema.colorScheme.onSurfaceVariant),
              const SizedBox(width: FletwaySpacing.sm),
              Expanded(
                child: Text(
                  '${o.vehiculoTipo} · ${o.cantidadViajes} '
                  '${o.cantidadViajes == 1 ? 'viaje' : 'viajes'} · $ayudantes'
                  '${o.cantidadAyudantes == ayudantesPedidos ? '' : ' (pediste $ayudantesPedidos)'}',
                  style: tema.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: FletwaySpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(o.precioCalculado.pesos,
                    style: tema.textTheme.headlineSmall),
              ),
              FletwayButton(
                texto: 'Elegir',
                icono: Icons.check,
                onPressed: onElegir,
              ),
            ],
          ),
          Text('IVA incluido', style: tema.textTheme.bodySmall),
        ],
      ),
    );
  }
}
