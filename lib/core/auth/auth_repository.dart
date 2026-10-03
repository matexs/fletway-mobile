import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client.dart';
import 'app_user.dart';

/// Repositorio de credenciales sobre el cliente de Supabase ([SupabaseInit]).
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(SupabaseInit.client),
);

/// Autenticación vía Supabase Auth (GoTrue). El signUp crea la fila `usuario`
/// con un trigger de la base; la fila del rol la crea el backend después
/// (`PerfilRepository.completarRegistro`, D-18).
class AuthRepository {
  /// Crea el repositorio sobre el cliente de Supabase.
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Eventos de sesión (login, logout, refresh del token).
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sesión vigente, o null si no hay usuario logueado.
  Session? get currentSession => _client.auth.currentSession;

  /// Inicia sesión con email y contraseña. Lanza `AuthException` (por ejemplo
  /// `invalid_credentials`).
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Crea la cuenta en GoTrue con `rol`, `nombre_completo` y `telefono` en la
  /// metadata, que el trigger de alta usa para crear la fila `usuario` (D-18).
  /// Devuelve true si quedó una sesión iniciada; false si el proyecto pide
  /// confirmar el email antes (D-17 dice que no, pero no se asume). Lanza
  /// `AuthException` (por ejemplo `user_already_exists`).
  Future<bool> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String nombreCompleto,
    required String telefono,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'rol': role.name,
        'nombre_completo': nombreCompleto,
        'telefono': telefono,
      },
    );
    return res.session != null;
  }

  /// Cierra la sesión.
  Future<void> signOut() => _client.auth.signOut();
}
