# Estado del proyecto — fletway-mobile

> Foto viva del avance. Actualizar al cerrar cada bloque. Fechas absolutas.

**Última actualización:** 2026-09-07 · **Etapa:** scaffolding inicial

---

## Resumen de una línea

Estructura Flutter feature-first creada con Riverpod + go_router y los archivos de
contexto/skills; **sin `flutter create` corrido** (falta toolchain) y **sin
pantallas de negocio reales** todavía — solo el esqueleto de `core/` y `app/`.

---

## Qué está hecho

| Área | Estado | Notas |
|------|--------|-------|
| Estructura de carpetas | ✅ | `lib/{app,core,shared,features/{auth,client,carrier}}`, `test/`, `docs/`, `.claude/`. |
| `pubspec.yaml` / `analysis_options.yaml` | ✅ | Deps fijadas: riverpod, go_router, dio, supabase_flutter, geolocator, freezed. |
| Archivos de contexto | ✅ | `CLAUDE.md`, este archivo, `ARQUITECTURA.md`, `API_CONTRATOS.md`. |
| Skills de Claude Code | ✅ | `new-screen`, `sync-api-models`, `feature-scaffold`. |
| Esqueleto `lib/core/` + `lib/app/` | ✅ (skeleton) | `env`, `api_client` (Dio + JWT interceptor), `supabase_client`, `auth` (sesión + rol), `router`, `theme`, `main.dart`. No compilado (sin toolchain). |
| Carpetas de plataforma (`android/`, `ios/`, …) | ❌ | Se generan con `flutter create .`. |
| `flutter pub get` / código generado | ❌ | Pendiente (sin toolchain). |
| Pantallas de negocio (Cliente / Transportista) | ❌ | Solo placeholders de estructura. |

---

## Pendientes / próximos pasos (ordenados)

1. **Instalar Flutter** y correr `flutter create .` en la raíz (respeta `lib/`,
   `pubspec.yaml`, `test/`).
2. `flutter pub get` + `dart run build_runner build --delete-conflicting-outputs`.
3. Completar `.env` (`SUPABASE_ANON_KEY`, `API_BASE_URL`).
4. Cerrar el esqueleto de `core/`: verificar que `api_client` inyecta el JWT de la
   sesión de Supabase en `Authorization`, y que `supabase_client` levanta bien.
5. **Auth primero** (RF-05 / RF-16 + login): pantallas en `features/auth/` con la
   skill `new-screen`; guard de rol en `app/router.dart`.
6. Con el primer endpoint del backend listo, correr `sync-api-models` para generar
   los DTOs de esa feature.
7. Feature por feature siguiendo `docs/API_CONTRATOS.md` y la prioridad del backend.

---

## Bloqueos conocidos

- **Flutter no instalado** en el entorno de scaffolding → sin `flutter create`, sin
  `pub get`, sin `analyze`. El código de `lib/` es un esqueleto no verificado.
- Depende de que `fletway-backend` publique endpoints en
  `../fletway-backend/docs/ENDPOINTS.md` (hoy solo health checks).
- `SUPABASE_ANON_KEY` real pendiente.

---

## Bitácora

| Fecha | Hito |
|-------|------|
| 2026-09-07 | Scaffolding inicial: estructura feature-first, core/app skeleton, contexto, 3 skills. Sin `flutter create`. |
