import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client.dart';
import 'app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(SupabaseInit.client),
);

/// Autenticación vía Supabase Auth (GoTrue). El alta de perfil (crear `usuario` +
/// `cliente`/`transportista`, cargar documentos del Transportista RF-16) se hace
/// contra el backend Go DESPUÉS del signUp — ver features/auth.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Crea las credenciales en GoTrue. `data` viaja como user_metadata y el
  /// backend la usa/verifica al crear el perfil.
  Future<void> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String nombreCompleto,
    required String telefono,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'rol': role.name,
        'nombre_completo': nombreCompleto,
        'telefono': telefono,
      },
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
