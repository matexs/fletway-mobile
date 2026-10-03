import 'package:flutter/material.dart';

import 'fletway_button.dart';

/// Pide confirmación antes de una acción que no se puede deshacer (CLAUDE.md §5,
/// "Componentes compartidos"). Devuelve true si el usuario confirma y false si
/// cancela o cierra el diálogo.
Future<bool> confirmarFletway(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoConfirmar,
  String textoCancelar = 'Volver',
  IconData icono = Icons.help_outline,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => FletwayConfirmDialog(
      titulo: titulo,
      mensaje: mensaje,
      textoConfirmar: textoConfirmar,
      textoCancelar: textoCancelar,
      icono: icono,
    ),
  );
  return confirmado ?? false;
}

/// Diálogo de confirmación de la app. Usarlo con [confirmarFletway]; no usar
/// `AlertDialog` directamente fuera de `lib/shared/widgets/`.
class FletwayConfirmDialog extends StatelessWidget {
  /// Crea el diálogo. Cierra con true al confirmar y con false al cancelar.
  const FletwayConfirmDialog({
    required this.titulo,
    required this.mensaje,
    required this.textoConfirmar,
    this.textoCancelar = 'Volver',
    this.icono = Icons.help_outline,
    super.key,
  });

  /// Pregunta corta.
  final String titulo;

  /// Qué pasa si confirma.
  final String mensaje;

  /// Texto del botón de confirmar (la acción, no "Aceptar").
  final String textoConfirmar;

  /// Texto del botón de cancelar.
  final String textoCancelar;

  /// Ícono arriba del título.
  final IconData icono;

  @override
  Widget build(BuildContext context) => AlertDialog(
        icon: Icon(icono),
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          FletwayButton(
            texto: textoCancelar,
            variante: FletwayButtonVariante.texto,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FletwayButton(
            texto: textoConfirmar,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
}
