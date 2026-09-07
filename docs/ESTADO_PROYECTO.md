# Estado del proyecto — fletway-mobile

> Foto viva del avance. Actualizar al cerrar cada bloque. Fechas absolutas.

**Última actualización:** 2026-09-07 · **Etapa:** scaffolding — proyecto Flutter compilando

---

## Resumen de una línea

Proyecto Flutter completo y **verificado** (`flutter create` + `pub get` +
`flutter analyze` sin issues + `build_runner` OK); estructura feature-first con
Riverpod 3 + go_router 18, esqueleto de `core/` y `app/` funcional. **Sin
pantallas de negocio reales** todavía — solo el router con placeholders.

---

## Qué está hecho

| Área | Estado | Notas |
|------|--------|-------|
| Estructura de carpetas | ✅ | `lib/{app,core,shared,features/{auth,client,carrier}}`, `test/`, `docs/`, `.claude/`. |
| `pubspec.yaml` | ✅ | Deps resueltas contra Flutter 3.47.2 / Dart 3.13.2: `flutter_riverpod ^3.1.0`, `go_router ^18.0.1`, `dio ^5.11.1`, `supabase_flutter ^2.17.2`, `geolocator ^14.0.3`, `freezed ^3.2.3`, etc. `pubspec.lock` versionado. |
| Carpetas de plataforma | ✅ | `android/` + `ios/` generadas con `flutter create . --org com.fletway --platforms=android,ios`. |
| `flutter analyze` | ✅ | **No issues found.** |
| `build_runner` | ✅ | Corre OK (0 outputs — todavía no hay clases `freezed`/`json`). |
| Esqueleto `lib/core/` + `lib/app/` | ✅ | `env` (con `SUPABASE_PUBLISHABLE_KEY` + fallback `SUPABASE_ANON_KEY`), `api_client` (Dio + `AuthInterceptor` con JWT de Supabase), `supabase_client` (Auth+Realtime, PKCE), `auth` (sesión + rol), `router` (go_router con redirect/guards por rol), `theme`, `main.dart`. |
| Archivos de contexto | ✅ | `CLAUDE.md`, este archivo, `ARQUITECTURA.md`, `API_CONTRATOS.md`. |
| Skills de Claude Code | ✅ | `new-screen`, `sync-api-models`, `feature-scaffold`. |
| CI + pre-commit | ✅ | `.github/workflows/ci.yml` (pub get → codegen → format → analyze → custom_lint → test); `scripts/pre-commit`. |
| Pantallas de negocio (Cliente / Transportista) | ❌ | El router tiene solo `_Placeholder`. |
| Toolchain Android (SDK, emulador) | ❌ | No instalado. No hace falta para analyze/test/codegen; sí para `flutter run`. |

---

## Pendientes / próximos pasos (ordenados)

1. Completar `.env` real (`API_BASE_URL`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`).
2. **Auth primero** (RF-05 / RF-16 + login): pantallas en `features/auth/` con la
   skill `new-screen`; el `authControllerProvider` ya alimenta el guard de rol.
   Falta traer el perfil del backend (rol + estado de habilitación) — hoy se
   deriva de `user_metadata` del JWT (ver `TODO` en `auth_controller.dart`).
3. Con el primer endpoint del backend publicado en
   `../fletway-backend/docs/ENDPOINTS.md`, correr `sync-api-models`.
4. Feature por feature siguiendo `docs/API_CONTRATOS.md` y la prioridad del backend.
5. Para correr en emulador: instalar Android Studio (`winget install Google.AndroidStudio`),
   abrirlo una vez (instala Android SDK), `flutter doctor --android-licenses`. Si
   Gradle se queja del Java 8 del sistema: `flutter config --jdk-dir "<Android Studio>\jbr"`.

---

## Bloqueos conocidos

- Depende de que `fletway-backend` publique endpoints en
  `../fletway-backend/docs/ENDPOINTS.md` (hoy solo health checks).
- `SUPABASE_PUBLISHABLE_KEY` real pendiente.
- Aviso benigno de `build_runner`: el paquete `analyzer` transitivo va una versión
  detrás del SDK (`language version 3.11.0` vs `3.13.0`). No rompe nada; se resuelve
  con `flutter pub upgrade` cuando convenga.

---

## Bitácora

| Fecha | Hito |
|-------|------|
| 2026-09-07 | Scaffolding inicial: estructura feature-first, core/app skeleton, contexto, 3 skills. |
| 2026-09-07 | Flutter 3.47.2 instalado (`C:\src\flutter`). `flutter create` (android/ios), `pub get` (deps a Riverpod 3 / go_router 18 / freezed 3), `flutter analyze` sin issues, `build_runner` OK. Añadidos CI + pre-commit. |
