import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/app_user.dart';
import '../../../core/auth/auth_repository.dart';
import 'validadores.dart';

/// Resultado del alta de credenciales.
enum ResultadoRegistro {
  /// Quedó una sesión iniciada: el `AuthController` completa el registro en el
  /// backend y el router navega.
  sesionIniciada,

  /// El proyecto pidió confirmar el email antes de iniciar sesión.
  confirmarEmail,
}

/// Estado del envío del formulario de registro; null mientras no se envió.
/// Depende de [authRepositoryProvider].
final registroControllerProvider =
    AsyncNotifierProvider.autoDispose<RegistroController, ResultadoRegistro?>(
        RegistroController.new);

/// Crea la cuenta en Supabase Auth con el rol y los datos personales en la
/// metadata (RF-05, RF-16, D-18). La fila del rol la crea después el
/// `AuthController`, con el JWT de la sesión nueva.
class RegistroController extends AsyncNotifier<ResultadoRegistro?> {
  @override
  ResultadoRegistro? build() => null;

  /// Crea la cuenta. El error (por ejemplo `user_already_exists`) queda en el
  /// estado como `AsyncError`.
  Future<void> registrar({
    required UserRole rol,
    required String nombreCompleto,
    required String telefono,
    required String email,
    required String contrasena,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final conSesion = await ref.read(authRepositoryProvider).signUp(
            email: email.trim(),
            password: contrasena,
            role: rol,
            nombreCompleto: nombreCompleto.trim(),
            telefono: ValidadoresAuth.normalizarTelefono(telefono),
          );
      return conSesion
          ? ResultadoRegistro.sesionIniciada
          : ResultadoRegistro.confirmarEmail;
    });
  }
}
