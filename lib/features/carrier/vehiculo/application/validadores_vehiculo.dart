import '../../../../shared/widgets/fletway_text_field.dart';

/// Validaciones de forma de los formularios de vehículo y costos. Repiten las
/// reglas del backend (ENDPOINTS.md, "Vehículos y costos") para avisar antes de
/// enviar; el backend las vuelve a controlar.
class ValidadoresVehiculo {
  const ValidadoresVehiculo._();

  static final _patente =
      RegExp(r'^([A-Z]{3}[0-9]{3}|[A-Z]{2}[0-9]{3}[A-Z]{2})$');

  /// Quita espacios, guiones y puntos de la patente y la pasa a mayúsculas.
  static String normalizarPatente(String valor) =>
      valor.replaceAll(RegExp(r'[\s\-.]'), '').toUpperCase();

  /// Exige una patente AAA999 o AA999AA.
  static String? patente(String? valor) {
    final v = normalizarPatente(valor ?? '');
    if (v.isEmpty) return 'Ingresá la patente.';
    if (!_patente.hasMatch(v)) return 'Formato AAA999 o AA999AA.';
    return null;
  }

  /// Devuelve un validador de un número decimal en el rango dado. Con
  /// [minExclusivo] el mínimo no está permitido (por ejemplo, medidas > 0).
  static String? Function(String?) rango({
    required double min,
    required double max,
    bool minExclusivo = false,
  }) =>
      (valor) {
        final n = FletwayTextField.leerDecimal(valor);
        if (n == null) return 'Ingresá un número.';
        if (minExclusivo ? n <= min : n < min) {
          return minExclusivo
              ? 'Tiene que ser mayor que 0.'
              : 'No puede ser negativo.';
        }
        if (n > max) return 'No puede superar ${_texto(max)}.';
        return null;
      };

  /// Devuelve un validador de un entero en el rango dado.
  static String? Function(String?) entero(
          {required int min, required int max}) =>
      (valor) {
        final n = int.tryParse((valor ?? '').trim());
        if (n == null) return 'Ingresá un número entero.';
        if (n < min || n > max) return 'Entre $min y $max.';
        return null;
      };

  static String _texto(double n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toString();
}
