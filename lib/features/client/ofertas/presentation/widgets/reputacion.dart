import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/extensions/numeros.dart';

/// Calificación y cumplimiento de un Transportista en una línea. Sin reseñas
/// muestra "Nuevo en Fletway" en vez de una calificación (el score usa 3,5
/// neutral, D-25).
class Reputacion extends StatelessWidget {
  /// Crea la línea de reputación.
  const Reputacion({
    required this.calificacion,
    required this.cantidadResenas,
    required this.tasaCumplimiento,
    super.key,
  });

  /// Promedio de 1 a 5, o null sin reseñas.
  final double? calificacion;

  /// Cantidad de reseñas.
  final int cantidadResenas;

  /// Porcentaje de viajes cumplidos, de 0 a 100.
  final double tasaCumplimiento;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estilo = tema.textTheme.bodyMedium;
    final c = calificacion;
    return Wrap(
      spacing: FletwaySpacing.md,
      runSpacing: FletwaySpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(c == null ? Icons.fiber_new_outlined : Icons.star_rounded,
                size: FletwaySpacing.lg, color: tema.colorScheme.primary),
            const SizedBox(width: FletwaySpacing.xs),
            Text(
              c == null
                  ? 'Nuevo en Fletway'
                  : '${c.toStringAsFixed(1).replaceAll('.', ',')} '
                      '($cantidadResenas '
                      '${cantidadResenas == 1 ? 'reseña' : 'reseñas'})',
              style: estilo,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined,
                size: FletwaySpacing.lg, color: tema.colorScheme.primary),
            const SizedBox(width: FletwaySpacing.xs),
            Text('${tasaCumplimiento.legible} % cumplidos', style: estilo),
          ],
        ),
      ],
    );
  }
}
