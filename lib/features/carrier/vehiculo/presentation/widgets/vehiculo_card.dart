import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/extensions/numeros.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../data/vehiculo_dto.dart';

/// Un vehículo del Transportista con sus medidas y el interruptor de activo
/// (RF-18). Los costos que entran en el precio son de referencia por tipo de
/// vehículo y los define la plataforma (D-34).
class VehiculoCard extends StatelessWidget {
  /// Crea la card. [onActivo] se dispara al mover el interruptor.
  const VehiculoCard({
    required this.vehiculo,
    required this.onActivo,
    super.key,
  });

  /// Vehículo a mostrar.
  final Vehiculo vehiculo;

  /// Cambia el estado activo. Null deshabilita el interruptor.
  final ValueChanged<bool>? onActivo;

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
        ],
      ),
    );
  }
}
