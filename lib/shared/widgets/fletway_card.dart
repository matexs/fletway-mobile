import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Card de la app (CLAUDE.md §5, "Componentes compartidos"). Las tarjetas de
/// cada feature (oferta, viaje, solicitud) se componen con este widget; no usar
/// `Card` directamente fuera de `lib/shared/widgets/`.
///
/// Si [onTap] no es null, toda la card es tocable.
class FletwayCard extends StatelessWidget {
  /// Crea una card con el contenido [child].
  const FletwayCard({required this.child, this.onTap, super.key});

  /// Contenido de la card. El padding interno lo pone la card.
  final Widget child;

  /// Acción al tocar la card; null la deja estática.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final contenido = Padding(
      padding: const EdgeInsets.all(FletwaySpacing.lg),
      child: child,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child:
          onTap == null ? contenido : InkWell(onTap: onTap, child: contenido),
    );
  }
}
