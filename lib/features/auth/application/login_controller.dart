import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_repository.dart';

/// Estado del envío del formulario de login. Depende de [authRepositoryProvider].
final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
        LoginController.new);

/// Inicia sesión en Supabase Auth. Al lograrlo, el `AuthController` recibe el
/// evento de sesión, pide el perfil y el router navega según el rol.
class LoginController extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Inicia sesión. El error (por ejemplo `invalid_credentials`) queda en el
  /// estado como `AsyncError`.
  Future<void> ingresar({
    required String email,
    required String contrasena,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signInWithPassword(email: email.trim(), password: contrasena),
    );
  }
}
