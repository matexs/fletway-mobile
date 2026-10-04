import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/extensions/numeros.dart';
import '../../data/oferta_dto.dart';

/// Cómo se forma el precio de una oferta (RN-01): sólo lo ve el Transportista
/// (D-23). Se muestra plegado para no cargar la pantalla.
class DesgloseOfertaView extends StatelessWidget {
  /// Crea el desglose de [desglose].
  const DesgloseOfertaView({required this.desglose, super.key});

  /// Valores a mostrar.
  final DesgloseOferta desglose;

  @override
  Widget build(BuildContext context) {
    final d = desglose;
    final tema = Theme.of(context);
    final filas = [
      (
        'Recorrido (ida)',
        '${d.distanciaKm.legible} km · ${d.duracionRutaH.duracion}'
      ),
      ('Carga y descarga', d.duracionOperacionH.duracion),
      ('Costo laboral', d.costoLaboral.pesos),
      ('Costo del vehículo', d.costoVehiculo.pesos),
      if (d.costosAdicionales > 0)
        ('Costos adicionales', d.costosAdicionales.pesos),
      ('Costo operativo', d.costoOperativo.pesos),
      (
        'Margen (${d.margenPct.legible} %)',
        (d.costoOperativo * d.margenPct / 100).pesos
      ),
      (
        'Comisión Fletway (${d.porcentajeComision.legible} %)',
        (d.precioNeto * d.porcentajeComision / 100).pesos,
      ),
      ('Precio sin IVA', d.precioNeto.pesos),
      ('IVA (${d.ivaPct.legible} %)', (d.precioNeto * d.ivaPct / 100).pesos),
    ];
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading:
          Icon(Icons.receipt_long_outlined, color: tema.colorScheme.primary),
      title: const Text('Cómo se calcula'),
      subtitle:
          const Text('Ida y vuelta por viaje; el Cliente sólo ve el total.'),
      childrenPadding: const EdgeInsets.only(bottom: FletwaySpacing.md),
      children: [
        for (final (etiqueta, valor) in filas)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: FletwaySpacing.xs),
            child: Row(
              children: [
                Expanded(
                    child: Text(etiqueta, style: tema.textTheme.bodyMedium)),
                Text(valor, style: tema.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}
