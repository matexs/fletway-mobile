import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/extensions/numeros.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../data/vehiculo_dto.dart';

/// Un vehículo del Transportista con sus medidas, el interruptor de activo y el
/// acceso a sus costos (RF-18). Avisa si faltan los costos: sin ellos no puede
/// ofertar con este vehículo (RN-01).
class VehiculoCard extends StatelessWidget {
  /// Crea la card. [onActivo] se dispara al mover el interruptor y [onCostos]
  /// al tocar el botón de costos.
  const VehiculoCard({
    required this.vehiculo,
    required this.onActivo,
    required this.onCostos,
    super.key,
  });

  /// Vehículo a mostrar.
  final Vehiculo vehiculo;

  /// Cambia el estado activo. Null deshabilita el interruptor.
  final ValueChanged<bool>? onActivo;

  /// Abre la pantalla de costos.
  final VoidCallback onCostos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final v = vehiculo;
    final marcaModelo = [v.marca, v.modelo].whereType<String>().join(' ');
    return FletwayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${v.tipoVehiculoNombre} · ${v.patente}',
                  style: tema.textTheme.titleMedium,
                ),
              ),
              Switch(value: v.activo, onChanged: onActivo),
            ],
          ),
          if (marcaModelo.isNotEmpty)
            Text(marcaModelo, style: tema.textTheme.bodyMedium),
          const SizedBox(height: FletwaySpacing.xs),
          Text(
            'Caja de ${v.largoUtilM.paraCampo} × ${v.anchoUtilM.paraCampo} × '
            '${v.altoUtilM.paraCampo} m · carga útil ${v.pesoMaximoKg.legible} kg',
            style: tema.textTheme.bodySmall,
          ),
          if (!v.activo) ...[
            const SizedBox(height: FletwaySpacing.xs),
            Text(
              'Inactivo: no se usa para ofertar.',
              style: tema.textTheme.bodySmall,
            ),
          ],
          if (!v.tieneCostos) ...[
            const SizedBox(height: FletwaySpacing.sm),
            Text(
              'Faltan los costos: sin ellos no podés ofertar con este vehículo.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.extension<FletwayEstados>()!.advertencia,
              ),
            ),
          ],
          const SizedBox(height: FletwaySpacing.md),
          FletwayButton(
            texto: v.tieneCostos ? 'Editar costos' : 'Cargar costos',
            icono: Icons.payments_outlined,
            variante: v.tieneCostos
                ? FletwayButtonVariante.secundario
                : FletwayButtonVariante.primario,
            onPressed: onCostos,
          ),
        ],
      ),
    );
  }
}
