import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto de la app, para formularios (CLAUDE.md §5, "Componentes
/// compartidos"). No usar `TextField` ni `TextFormField` directamente fuera de
/// `lib/shared/widgets/`.
///
/// Se integra con `Form`: [validator] devuelve el mensaje de error o null si el
/// valor es válido.
class FletwayTextField extends StatelessWidget {
  /// Crea un campo con la [etiqueta] visible sobre el valor.
  const FletwayTextField({
    required this.etiqueta,
    this.controller,
    this.ayuda,
    this.validator,
    this.onChanged,
    this.teclado,
    this.formateadores,
    this.oculto = false,
    this.habilitado = true,
    this.accionTeclado,
    super.key,
  });

  /// Etiqueta del campo.
  final String etiqueta;

  /// Controlador opcional del texto.
  final TextEditingController? controller;

  /// Texto de ayuda debajo del campo (por ejemplo, la unidad esperada).
  final String? ayuda;

  /// Validación: devuelve el mensaje de error, o null si el valor es válido.
  final FormFieldValidator<String>? validator;

  /// Se dispara con cada cambio del texto.
  final ValueChanged<String>? onChanged;

  /// Tipo de teclado (email, número, etc.).
  final TextInputType? teclado;

  /// Restricciones de entrada, por ejemplo sólo dígitos.
  final List<TextInputFormatter>? formateadores;

  /// Si es true, oculta el texto (contraseñas).
  final bool oculto;

  /// Si es false, el campo es de sólo lectura y se ve deshabilitado.
  final bool habilitado;

  /// Acción del botón del teclado (siguiente, listo, etc.).
  final TextInputAction? accionTeclado;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        keyboardType: teclado,
        inputFormatters: formateadores,
        obscureText: oculto,
        enabled: habilitado,
        textInputAction: accionTeclado,
        decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
      );
}
