import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Inicializa y expone el cliente de Supabase.
///
/// Uso en esta app (modelo híbrido — ver docs/ARQUITECTURA.md §5):
///  - **Auth (GoTrue):** login, registro de credenciales, refresh de sesión.
///  - **Realtime:** chat sobre `mensaje` (RF-10/RF-20/RI-05) y ubicación en vivo
///    sobre `viaje_ubicacion` (RF-15/RI-04).
///
/// El CRUD de negocio (solicitudes, ofertas, viajes, pagos, PIN) NO pasa por acá:
/// va al backend Go vía `ApiClient`.
class SupabaseInit {
  const SupabaseInit._();

  static Future<void> ensureInitialized() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// JWT de la sesión actual, o null si no hay sesión.
  /// Lo consume `AuthInterceptor` para el header Authorization del backend.
  static String? get accessToken => client.auth.currentSession?.accessToken;
}
