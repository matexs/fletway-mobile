import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../error/failure.dart';
import '../network/api_exception.dart';
import 'app_user.dart';
import 'auth_repository.dart';
import 'perfil_repository.dart';

/// Etapas de la sesión que observa el router.
enum AuthEstado {
  /// Sin sesión de Supabase.
  noAutenticado,

  /// Hay sesión y se está pidiendo el perfil al backend.
  cargando,

  /// Hay sesión y perfil: [AuthSessionState.user] no es null.
  autenticado,

  /// Hay sesión pero no se pudo obtener un perfil usable.
  error,
}

/// Estado de sesión observado por el router (`app/router.dart`) para los guards
/// por rol.
@immutable
class AuthSessionState {
  /// Crea el estado; por defecto, sin sesión.
  const AuthSessionState({
    this.estado = AuthEstado.noAutenticado,
    this.user,
    this.falla,
  });

  /// Etapa de la sesión.
  final AuthEstado estado;

  /// Usuario con su rol, sólo en [AuthEstado.autenticado].
  final AppUser? user;

  /// Motivo del error, sólo en [AuthEstado.error].
  final Failure? falla;

  /// true si hay usuario con perfil cargado.
  bool get isAuthenticated => estado == AuthEstado.autenticado && user != null;
}

/// Sesión y perfil del usuario. Depende de [authRepositoryProvider] (Supabase
/// Auth) y de [perfilRepositoryProvider] (backend).
final authControllerProvider =
    NotifierProvider<AuthController, AuthSessionState>(AuthController.new);

/// Mantiene la sesión y resuelve el rol con `GET /me` (D-18), nunca con
/// `user_metadata`. Si la cuenta todavía no tiene la fila de su rol (la app se
/// cerró entre el signUp y el registro), completa el registro, que es idempotente.
class AuthController extends Notifier<AuthSessionState> {
  // Descarta resultados de cargas viejas si llega un evento de sesión nuevo
  // mientras se espera al backend.
  int _carga = 0;

  @override
  AuthSessionState build() {
    final repo = ref.watch(authRepositoryProvider);

    final sub = repo.onAuthStateChange.listen(_onAuthEvent);
    ref.onDispose(sub.cancel);

    if (repo.currentSession != null) {
      Future.microtask(cargarPerfil);
      return const AuthSessionState(estado: AuthEstado.cargando);
    }
    return const AuthSessionState();
  }

  /// Pide el perfil al backend y deja el estado en autenticado o error. Lo usa
  /// también el botón "Reintentar" de la pantalla de inicio. Efectos: red
  /// (`GET /me` y, si falta, `POST /auth/registro/...`); cierra la sesión si el
  /// backend rechaza el JWT.
  Future<void> cargarPerfil() async {
    final carga = ++_carga;
    state = const AuthSessionState(estado: AuthEstado.cargando);
    final perfil = ref.read(perfilRepositoryProvider);
    try {
      var me = await perfil.me();
      final user = AppUser.fromMe(me);
      if (user.role == UserRole.administrador) {
        _publicar(
          carga,
          const AuthSessionState(
            estado: AuthEstado.error,
            falla: Failure(
              'Las cuentas de Administrador no usan la app móvil.',
              code: 'rol_sin_app',
            ),
          ),
        );
        return;
      }
      if (!me.registroCompleto) {
        me = await perfil.completarRegistro(user.role);
      }
      _publicar(
        carga,
        AuthSessionState(
          estado: AuthEstado.autenticado,
          user: AppUser.fromMe(me),
        ),
      );
    } on ApiException catch (e) {
      if (e.isAuth) {
        await ref.read(authRepositoryProvider).signOut();
        return;
      }
      _publicar(
        carga,
        AuthSessionState(estado: AuthEstado.error, falla: Failure.from(e)),
      );
    } on FormatException catch (e) {
      _publicar(
        carga,
        AuthSessionState(estado: AuthEstado.error, falla: Failure.from(e)),
      );
    }
  }

  /// Cierra la sesión en Supabase; el estado pasa a no autenticado con el evento.
  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();

  void _publicar(int carga, AuthSessionState nuevo) {
    if (ref.mounted && carga == _carga) state = nuevo;
  }

  void _onAuthEvent(sb.AuthState event) {
    if (event.session == null) {
      _carga++;
      state = const AuthSessionState();
      return;
    }
    // Sólo un login nuevo (o un usuario distinto) requiere pedir el perfil; los
    // refresh del token no cambian el rol.
    final mismoUsuario = state.user?.id == event.session!.user.id;
    if (event.event == sb.AuthChangeEvent.signedIn &&
        !(state.isAuthenticated && mismoUsuario) &&
        state.estado != AuthEstado.cargando) {
      unawaited(cargarPerfil());
    }
  }
}
