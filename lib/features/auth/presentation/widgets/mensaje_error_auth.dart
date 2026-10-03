import 'package:flutter/material.dart';

import '../../../../shared/design_system/design_system.dart';

/// Mensaje de error de un formulario de auth (credenciales inválidas, email ya
/// registrado), debajo de los campos. No muestra nada si [mensaje] es null.
class MensajeErrorAuth extends StatelessWidget {
  /// Crea el mensaje; [mensaje] null no ocupa espacio.
  const MensajeErrorAuth({required this.mensaje, super.key});

  /// Texto para el usuario, ya traducido con `Failure.from`.
  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    if (mensaje == null) return const SizedBox.shrink();
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: FletwaySpacing.md),
      child: Text(
        mensaje!,
        style: tema.textTheme.bodyMedium?.copyWith(
          color: tema.colorScheme.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
