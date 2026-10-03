import 'package:intl/intl.dart';

final _sinMiles = NumberFormat('0.##', 'es_AR');
final _conMiles = NumberFormat('#,##0.##', 'es_AR');

/// Formato de números en es-AR (coma decimal), para medidas y montos.
extension FormatoNumero on num {
  /// Hasta 2 decimales, sin separador de miles: `2,4`, `28000000`. Sirve para
  /// precargar campos [FletwayTextField.decimal].
  String get paraCampo => _sinMiles.format(this);

  /// Hasta 2 decimales, con separador de miles: `28.000.000`, `1.350,5`.
  String get legible => _conMiles.format(this);
}
