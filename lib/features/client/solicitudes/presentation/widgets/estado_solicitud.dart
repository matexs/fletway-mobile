import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';

/// Ícono, color y texto de cada estado de una solicitud.
({IconData icono, Color color, String texto}) estiloEstadoSolicitud(
  BuildContext context,
  String estado,
) {
  final tema = Theme.of(context);
  final estados = tema.extension<FletwayEstados>()!;
  return switch (estado) {
    'publicada' => (
        icono: Icons.campaign_outlined,
        color: tema.colorScheme.primary,
        texto: 'Publicada',
      ),
    'asignada' => (
        icono: Icons.check_circle_outline,
        color: estados.exito,
        texto: 'Con viaje confirmado',
      ),
    'vencida' => (
        icono: Icons.event_busy_outlined,
        color: estados.advertencia,
        texto: 'Vencida',
      ),
    'cancelada' => (
        icono: Icons.cancel_outlined,
        color: tema.colorScheme.onSurfaceVariant,
        texto: 'Cancelada',
      ),
    _ => (
        icono: Icons.history,
        color: tema.colorScheme.onSurfaceVariant,
        texto: 'Cerrada',
      ),
  };
}

/// Etiqueta del estado de una solicitud: ícono y texto con el color del estado.
class EstadoSolicitudChip extends StatelessWidget {
  /// Crea la etiqueta para [estado].
  const EstadoSolicitudChip({required this.estado, super.key});

  /// Código del estado (`publicada`, `vencida`, ...).
  final String estado;

  @override
  Widget build(BuildContext context) {
    final e = estiloEstadoSolicitud(context, estado);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(e.icono, size: FletwaySpacing.lg, color: e.color),
        const SizedBox(width: FletwaySpacing.xs),
        Text(
          e.texto,
          style:
              Theme.of(context).textTheme.labelLarge?.copyWith(color: e.color),
        ),
      ],
    );
  }
}
