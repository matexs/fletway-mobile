import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso tipado a las variables de entorno cargadas desde `.env`
/// (ver `.env.example`).
class Env {
  const Env._();

  static String get apiBaseUrl => _get('API_BASE_URL');
  static Duration get apiTimeout =>
      Duration(milliseconds: int.tryParse(dotenv.env['API_TIMEOUT_MS'] ?? '') ?? 15000);

  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');

  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get isDev => appEnv == 'development';

  static String _get(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Falta la variable de entorno "$key" (ver .env.example)');
    }
    return value;
  }

  /// Falla temprano si falta configuración obligatoria.
  static void validate() {
    _get('API_BASE_URL');
    _get('SUPABASE_URL');
    _get('SUPABASE_ANON_KEY');
  }
}
