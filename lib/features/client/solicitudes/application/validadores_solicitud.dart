import '../../../../shared/widgets/fletway_text_field.dart';

/// Validaciones de forma del formulario de publicación. Repiten las reglas del
/// backend (ENDPOINTS.md, "Solicitudes") para avisar antes de enviar.
class ValidadoresSolicitud {
  const ValidadoresSolicitud._();

  /// Dirección de 5 a 200 caracteres.
  static String? direccion(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'Ingresá la dirección.';
    if (v.length < 5) return 'Escribí calle y número.';
    if (v.length > 200) return 'Hasta 200 caracteres.';
    return null;
  }

  /// Pisos por escalera, de 0 a 60.
  static String? pisos(String? valor) {
    final n = int.tryParse((valor ?? '').trim());
    if (n == null) return 'Ingresá un número (0 si es planta baja).';
    if (n < 0 || n > 60) return 'Entre 0 y 60.';
    return null;
  }

  /// Distancia a pie del vehículo a la puerta, de 0 a 9999,9 m.
  static String? distancia(String? valor) {
    final n = FletwayTextField.leerDecimal(valor);
    if (n == null) return 'Ingresá los metros (0 si estaciona en la puerta).';
    if (n < 0 || n > 9999.9) return 'Entre 0 y 9999,9.';
    return null;
  }

  /// Nombre de un objeto manual, de 2 a 80 caracteres.
  static String? nombreObjeto(String? valor) {
    final v = (valor ?? '').trim();
    if (v.length < 2) return 'Escribí qué es.';
    if (v.length > 80) return 'Hasta 80 caracteres.';
    return null;
  }

  /// Devuelve un validador de una medida o peso mayor que 0 y hasta [max].
  static String? Function(String?) positivo(double max) => (valor) {
        final n = FletwayTextField.leerDecimal(valor);
        if (n == null) return 'Ingresá un número.';
        if (n <= 0) return 'Tiene que ser mayor que 0.';
        if (n > max) return 'No puede superar ${max.toInt()}.';
        return null;
      };
}
