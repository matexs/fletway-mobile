import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/widgets/widgets.dart';

/// Resumen del estado de habilitación del Transportista (RF-01, D-33), arriba de
/// la lista de documentos.
class EstadoHabilitacionBanner extends StatelessWidget {
  /// Crea el resumen para [estado] (`pendiente`, `habilitado` o `rechazado`).
  /// [faltanDocumentos] cambia el texto de `pendiente`: todavía no cargó todo.
  const EstadoHabilitacionBanner({
    required this.estado,
    required this.faltanDocumentos,
    super.key,
  });

  /// Código del estado de habilitación.
  final String estado;

  /// true si hay algún tipo sin documento cargado.
  final bool faltanDocumentos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.extension<FletwayEstados>()!;
    final (icono, color, titulo, detalle) = switch (estado) {
      'habilitado' => (
          Icons.verified_outlined,
          colores.exito,
          'Cuenta habilitada',
          'Ya podés ofertar en las solicitudes de tu zona.',
        ),
      'rechazado' => (
          Icons.error_outline,
          tema.colorScheme.error,
          'Documentación rechazada',
          'Revisá el motivo y volvé a cargar el documento. Podés intentarlo las '
              'veces que haga falta.',
        ),
      _ when faltanDocumentos => (
          Icons.upload_file_outlined,
          colores.advertencia,
          'Falta documentación',
          'Cargá los cuatro documentos para que podamos revisar tu cuenta.',
        ),
      _ => (
          Icons.hourglass_top_outlined,
          colores.advertencia,
          'Documentación en revisión',
          'Te avisamos cuando la revisemos.',
        ),
    };
    return FletwayCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color),
          const SizedBox(width: FletwaySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: tema.textTheme.titleMedium?.copyWith(color: color),
                ),
                const SizedBox(height: FletwaySpacing.xs),
                Text(detalle, style: tema.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
