import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Variantes visuales de [FletwayButton].
enum FletwayButtonVariante {
  /// Acción principal de la pantalla, con el color de marca.
  primario,

  /// Acción secundaria, con borde y sin relleno.
  secundario,

  /// Acción de menor peso, sólo texto.
  texto,
}

/// Botón de la app. Es el único botón que usan las pantallas (CLAUDE.md §5,
/// "Componentes compartidos"); no usar `FilledButton`, `OutlinedButton` ni
/// `TextButton` directamente fuera de `lib/shared/widgets/`.
///
/// Si [onPressed] es null o [cargando] es true, el botón queda deshabilitado.
/// Mientras [cargando] es true muestra un indicador en lugar del ícono.
class FletwayButton extends StatelessWidget {
  /// Crea un botón con el [texto] y la acción [onPressed].
  const FletwayButton({
    required this.texto,
    required this.onPressed,
    this.variante = FletwayButtonVariante.primario,
    this.icono,
    this.cargando = false,
    this.anchoCompleto = false,
    super.key,
  });

  /// Texto del botón.
  final String texto;

  /// Acción al tocarlo. Null deshabilita el botón.
  final VoidCallback? onPressed;

  /// Variante visual; por defecto, primario.
  final FletwayButtonVariante variante;

  /// Ícono opcional a la izquierda del texto.
  final IconData? icono;

  /// Si es true, deshabilita el botón y muestra un indicador de progreso.
  final bool cargando;

  /// Si es true, el botón ocupa todo el ancho disponible.
  final bool anchoCompleto;

  @override
  Widget build(BuildContext context) {
    final accion = cargando ? null : onPressed;
    final Widget? adelante = cargando
        ? const SizedBox.square(
            dimension: FletwaySpacing.lg,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (icono == null ? null : Icon(icono));
    final etiqueta = Text(texto);

    final Widget boton = switch (variante) {
      FletwayButtonVariante.primario => adelante == null
          ? FilledButton(onPressed: accion, child: etiqueta)
          : FilledButton.icon(
              onPressed: accion,
              icon: adelante,
              label: etiqueta,
            ),
      FletwayButtonVariante.secundario => adelante == null
          ? OutlinedButton(onPressed: accion, child: etiqueta)
          : OutlinedButton.icon(
              onPressed: accion,
              icon: adelante,
              label: etiqueta,
            ),
      FletwayButtonVariante.texto => adelante == null
          ? TextButton(onPressed: accion, child: etiqueta)
          : TextButton.icon(
              onPressed: accion,
              icon: adelante,
              label: etiqueta,
            ),
    };
    return anchoCompleto
        ? SizedBox(width: double.infinity, child: boton)
        : boton;
  }
}
