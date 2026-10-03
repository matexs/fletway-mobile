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
    this.sufijo,
    super.key,
  });

  /// Campo para números decimales (medidas, montos): teclado numérico y sólo
  /// dígitos con un separador decimal (coma o punto) y hasta [decimales]
  /// decimales. Leer el valor con [FletwayTextField.leerDecimal]. [sufijo] es la
  /// unidad que se muestra a la derecha (`m`, `kg`, `$`).
  FletwayTextField.decimal({
    required this.etiqueta,
    this.controller,
    this.ayuda,
    this.validator,
    this.onChanged,
    this.accionTeclado,
    this.sufijo,
    int decimales = 2,
    super.key,
  })  : teclado = TextInputType.numberWithOptions(decimal: decimales > 0),
        formateadores = [
          FilteringTextInputFormatter.allow(
            RegExp(
              decimales > 0 ? '^\\d*([.,]\\d{0,$decimales})?' : '^\\d*',
            ),
          ),
        ],
        oculto = false,
        habilitado = true;

  /// Convierte el texto de un campo [FletwayTextField.decimal] en número. Acepta
  /// coma o punto decimal. Devuelve null si está vacío o no es un número.
  static double? leerDecimal(String? texto) {
    final t = (texto ?? '').trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

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

  /// Texto fijo a la derecha del valor, por ejemplo la unidad.
  final String? sufijo;

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
        decoration: InputDecoration(
          labelText: etiqueta,
          helperText: ayuda,
          helperMaxLines: 3,
          suffixText: sufijo,
        ),
      );
}
