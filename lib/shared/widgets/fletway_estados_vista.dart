import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import 'fletway_button.dart';

/// Vista de carga: indicador de progreso centrado con un [mensaje] opcional.
/// Se usa en `AsyncValue.when(loading: ...)` (CLAUDE.md §5, "Pantallas").
class FletwayLoading extends StatelessWidget {
  /// Crea la vista de carga.
  const FletwayLoading({this.mensaje, super.key});

  /// Texto opcional debajo del indicador.
  final String? mensaje;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (mensaje != null) ...[
              const SizedBox(height: FletwaySpacing.lg),
              Text(mensaje!, textAlign: TextAlign.center),
            ],
          ],
        ),
      );
}

/// Vista de error: [mensaje] centrado y, si [onReintentar] no es null, un botón
/// para volver a intentar. Se usa en `AsyncValue.when(error: ...)`.
class FletwayErrorView extends StatelessWidget {
  /// Crea la vista de error.
  const FletwayErrorView({required this.mensaje, this.onReintentar, super.key});

  /// Mensaje para el usuario, sin detalles técnicos.
  final String mensaje;

  /// Acción del botón "Reintentar"; null lo oculta.
  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FletwaySpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: tema.colorScheme.error),
            const SizedBox(height: FletwaySpacing.md),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge,
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: FletwaySpacing.lg),
              FletwayButton(
                texto: 'Reintentar',
                onPressed: onReintentar,
                variante: FletwayButtonVariante.secundario,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vista vacía: [mensaje] centrado con un [icono] y una [accion] opcional (por
/// ejemplo, "Publicar solicitud"). Se usa cuando una lista no tiene elementos.
class FletwayEmptyView extends StatelessWidget {
  /// Crea la vista vacía.
  const FletwayEmptyView({
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
    this.accion,
    super.key,
  });

  /// Mensaje para el usuario.
  final String mensaje;

  /// Ícono ilustrativo.
  final IconData icono;

  /// Widget opcional debajo del mensaje, normalmente un [FletwayButton].
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FletwaySpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: tema.colorScheme.secondary),
            const SizedBox(height: FletwaySpacing.md),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge,
            ),
            if (accion != null) ...[
              const SizedBox(height: FletwaySpacing.lg),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}
