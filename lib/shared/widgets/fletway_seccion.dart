import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Encabezado de una sección de pantalla o formulario, con ícono (decoración
/// mínima, CLAUDE.md §5). [detalle] es un texto de ayuda opcional debajo.
class FletwaySeccion extends StatelessWidget {
  /// Crea el encabezado.
  const FletwaySeccion({
    required this.icono,
    required this.titulo,
    this.detalle,
    super.key,
  });

  /// Ícono de la sección.
  final IconData icono;

  /// Título de la sección.
  final String titulo;

  /// Ayuda opcional debajo del título.
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: tema.colorScheme.primary),
            const SizedBox(width: FletwaySpacing.sm),
            Expanded(child: Text(titulo, style: tema.textTheme.titleMedium)),
          ],
        ),
        if (detalle != null) ...[
          const SizedBox(height: FletwaySpacing.xs),
          Text(detalle!, style: tema.textTheme.bodySmall),
        ],
      ],
    );
  }
}
