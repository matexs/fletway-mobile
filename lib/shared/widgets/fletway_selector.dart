import 'package:flutter/material.dart';

/// Opción de un [FletwaySelector]: el [valor] y el texto que ve el usuario.
class FletwayOpcion<T> {
  /// Crea la opción.
  const FletwayOpcion({required this.valor, required this.texto});

  /// Valor que devuelve el selector al elegirla.
  final T valor;

  /// Texto de la opción.
  final String texto;
}

/// Selector de una opción entre varias, para formularios (CLAUDE.md §5,
/// "Componentes compartidos"). Se integra con `Form` como [FletwayTextField].
class FletwaySelector<T> extends StatelessWidget {
  /// Crea el selector con sus [opciones]. [onChanged] se dispara al elegir.
  const FletwaySelector({
    required this.etiqueta,
    required this.opciones,
    required this.onChanged,
    this.valor,
    this.ayuda,
    this.validator,
    super.key,
  });

  /// Etiqueta del campo.
  final String etiqueta;

  /// Opciones disponibles, en el orden en que se muestran.
  final List<FletwayOpcion<T>> opciones;

  /// Valor elegido, o null si todavía no se eligió.
  final T? valor;

  /// Se dispara con el valor elegido. Null deshabilita el selector.
  final ValueChanged<T?>? onChanged;

  /// Texto de ayuda debajo del campo.
  final String? ayuda;

  /// Validación: devuelve el mensaje de error, o null si el valor es válido.
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
        initialValue: valor,
        isExpanded: true,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
        items: [
          for (final o in opciones)
            DropdownMenuItem(value: o.valor, child: Text(o.texto)),
        ],
      );
}
