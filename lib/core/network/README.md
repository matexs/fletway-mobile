# core/network

- `api_client.dart`    — Dio + `apiClientProvider`. Único punto de HTTP al backend Go.
- `api_exception.dart` — parsea el envelope de error único `{error:{code,message,details}}`.
- `AuthInterceptor`    — inyecta el JWT de la sesión de Supabase en `Authorization`.
