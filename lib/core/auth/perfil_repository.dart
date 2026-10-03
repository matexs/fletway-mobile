import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/me.dart';
import '../network/api_client.dart';
import 'app_user.dart';

/// Repositorio del perfil del usuario autenticado en el backend Go. Depende de
/// [apiClientProvider].
final perfilRepositoryProvider = Provider<PerfilRepository>(
  (ref) => PerfilRepository(ref.watch(apiClientProvider)),
);

/// Perfil y alta de cuenta contra el backend (D-18). Requiere una sesión de
/// Supabase: el JWT lo agrega el `AuthInterceptor`.
class PerfilRepository {
  /// Crea el repositorio sobre [ApiClient].
  PerfilRepository(this._api);

  final ApiClient _api;

  /// Pide `GET /me`. Lanza `ApiException` (por ejemplo `usuario_no_encontrado`).
  Future<Me> me() async {
    final json = await _api.get<Map<String, dynamic>>('/me');
    return Me.fromJson(json);
  }

  /// Crea la fila del rol con `POST /auth/registro/{cliente|transportista}` y
  /// devuelve el perfil actualizado. Es idempotente. Lanza `ApiException`
  /// (`rol_no_corresponde`, `cuenta_inactiva`) o [ArgumentError] si [rol] es
  /// administrador.
  Future<Me> completarRegistro(UserRole rol) async {
    if (rol == UserRole.administrador) {
      throw ArgumentError.value(rol, 'rol', 'no se registra desde la app');
    }
    final json = await _api.post<Map<String, dynamic>>(
      '/auth/registro/${rol.name}',
    );
    return Me.fromJson(json);
  }
}
