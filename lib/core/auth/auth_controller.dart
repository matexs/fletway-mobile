import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'app_user.dart';
import 'auth_repository.dart';

/// Estado de sesión observado por el router (`app/router.dart`) para los guards
/// por rol. `null` en [AuthState.user] => no autenticado.
@immutable
class AuthSessionState {
  const AuthSessionState({this.user, this.loading = false});

  final AppUser? user;
  final bool loading;

  bool get isAuthenticated => user != null;

  AuthSessionState copyWith({AppUser? user, bool? loading, bool clearUser = false}) =>
      AuthSessionState(
        user: clearUser ? null : (user ?? this.user),
        loading: loading ?? this.loading,
      );
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthSessionState>(AuthController.new);

class AuthController extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() {
    final repo = ref.watch(authRepositoryProvider);

    final sub = repo.onAuthStateChange.listen(_onAuthEvent);
    ref.onDispose(sub.cancel);

    final session = repo.currentSession;
    if (session != null) {
      // TODO(fletway): al arrancar con sesión viva, pedir el perfil al backend
      // (GET /me) para resolver rol y estado de habilitación.
      return AuthSessionState(user: _userFromSession(session));
    }
    return const AuthSessionState();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(loading: true);
    try {
      await ref.read(authRepositoryProvider).signInWithPassword(
            email: email,
            password: password,
          );
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();

  void _onAuthEvent(sb.AuthState event) {
    final session = event.session;
    if (session == null) {
      state = state.copyWith(clearUser: true);
    } else {
      state = state.copyWith(user: _userFromSession(session));
    }
  }

  /// Resuelve un [AppUser] mínimo a partir de los claims del JWT. El rol viene de
  /// `user_metadata.rol` (seteado en signUp); el estado de habilitación real lo
  /// confirma el backend.
  AppUser _userFromSession(sb.Session session) {
    final u = session.user;
    final meta = u.userMetadata ?? const {};
    return AppUser(
      id: u.id,
      email: u.email ?? '',
      nombreCompleto: (meta['nombre_completo'] as String?) ?? '',
      role: (meta['rol'] as String?) == UserRole.transportista.name
          ? UserRole.transportista
          : UserRole.cliente,
    );
  }
}
