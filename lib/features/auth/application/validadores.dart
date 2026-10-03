/// Validaciones de forma de los formularios de login y registro. Devuelven el
/// mensaje de error o null si el valor es válido (contrato de `FormField`).
///
/// Son sólo de forma: la base vuelve a exigir nombre y teléfono (trigger de
/// alta, D-18) y Supabase Auth valida el email y la contraseña.
class ValidadoresAuth {
  const ValidadoresAuth._();

  /// Largo mínimo de contraseña que pide la app.
  static const largoMinimoContrasena = 8;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _telefono = RegExp(r'^\+?[0-9]{8,15}$');

  /// Exige un email con forma `algo@dominio.ext`.
  static String? email(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá tu email.';
    if (!_email.hasMatch(v)) return 'El email no es válido.';
    return null;
  }

  /// Exige una contraseña no vacía (login).
  static String? contrasenaIngresada(String? valor) =>
      (valor ?? '').isEmpty ? 'Ingresá tu contraseña.' : null;

  /// Exige al menos [largoMinimoContrasena] caracteres (registro).
  static String? contrasenaNueva(String? valor) {
    final v = valor ?? '';
    if (v.isEmpty) return 'Ingresá una contraseña.';
    if (v.length < largoMinimoContrasena) {
      return 'Usá al menos $largoMinimoContrasena caracteres.';
    }
    return null;
  }

  /// Exige que la confirmación coincida con [original].
  static String? confirmacion(String? valor, String original) =>
      valor == original ? null : 'Las contraseñas no coinciden.';

  /// Exige nombre y apellido (al menos dos palabras).
  static String? nombreCompleto(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá tu nombre y apellido.';
    if (v.split(RegExp(r'\s+')).length < 2) return 'Ingresá nombre y apellido.';
    return null;
  }

  /// Exige un teléfono de 8 a 15 dígitos, con `+` opcional; ignora espacios y
  /// guiones.
  static String? telefono(String? valor) {
    final v = normalizarTelefono(valor ?? '');
    if (v.isEmpty) return 'Ingresá tu teléfono.';
    if (!_telefono.hasMatch(v)) {
      return 'Ingresá sólo números, con código de área.';
    }
    return null;
  }

  /// Quita espacios, guiones y paréntesis del teléfono.
  static String normalizarTelefono(String valor) =>
      valor.replaceAll(RegExp(r'[\s\-()]'), '');
}
