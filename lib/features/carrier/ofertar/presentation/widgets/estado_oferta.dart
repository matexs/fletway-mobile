import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';

/// Etiqueta del estado de una oferta: ícono y texto con el color del estado.
class EstadoOfertaChip extends StatelessWidget {
  /// Crea la etiqueta para [estado].
  const EstadoOfertaChip({required this.estado, super.key});

  /// Código del estado (`pendiente`, `aceptada`, ...).
  final String estado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estados = tema.extension<FletwayEstados>()!;
    final (icono, color, texto) = switch (estado) {
      'pendiente' => (
          Icons.hourglass_empty,
          tema.colorScheme.primary,
          'Esperando al Cliente'
        ),
      'aceptada' => (Icons.check_circle_outline, estados.exito, 'Aceptada'),
      'no_seleccionada' => (
          Icons.do_not_disturb_on_outlined,
          tema.colorScheme.onSurfaceVariant,
          'No elegida'
        ),
      _ => (Icons.undo, tema.colorScheme.onSurfaceVariant, 'Retirada'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: FletwaySpacing.lg, color: color),
        const SizedBox(width: FletwaySpacing.xs),
        Flexible(
          child: Text(texto,
              style: tema.textTheme.labelLarge?.copyWith(color: color)),
        ),
      ],
    );
  }
}
