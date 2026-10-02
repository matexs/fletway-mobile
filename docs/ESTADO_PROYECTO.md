# Estado del proyecto — fletway-mobile

> Foto viva del avance. Actualizar al cerrar cada bloque. Fechas absolutas.

**Última actualización:** 2026-10-01 · **Etapa:** definiciones cerradas, listo para construir (ver `../fletway-backend/docs/PLAN_CONSTRUCCION.md`)

---

## Resumen de una línea

Proyecto Flutter completo y **verificado** (`flutter create` + `pub get` +
`flutter analyze` sin issues + `build_runner` OK); estructura feature-first con
Riverpod 3 + go_router 18, esqueleto de `core/` y `app/` funcional; convenciones de
código y UI definidas (`CLAUDE.md` §5). **Sin pantallas de negocio reales** todavía —
solo el router con placeholders.

---

## Qué está hecho

| Área | Estado | Notas |
|------|--------|-------|
| Estructura de carpetas | Hecho | `lib/{app,core,shared,features/{auth,client,carrier}}`, `test/`, `docs/`, `.claude/`. |
| `pubspec.yaml` | Hecho | Deps resueltas contra Flutter 3.47.2 / Dart 3.13.2: `flutter_riverpod ^3.1.0`, `go_router ^18.0.1`, `dio ^5.11.1`, `supabase_flutter ^2.17.2`, `geolocator ^14.0.3`, `freezed ^3.2.3`, etc. `pubspec.lock` versionado. |
| Carpetas de plataforma | Hecho | `android/` + `ios/` generadas con `flutter create . --org com.fletway --platforms=android,ios`. |
| `flutter analyze` | Hecho | **No issues found.** |
| `build_runner` | Hecho | Corre OK (0 outputs — todavía no hay clases `freezed`/`json`). |
| Esqueleto `lib/core/` + `lib/app/` | Hecho | `env` (con `SUPABASE_PUBLISHABLE_KEY` + fallback `SUPABASE_ANON_KEY`), `api_client` (Dio + `AuthInterceptor` con JWT de Supabase), `supabase_client` (Auth+Realtime, PKCE), `auth` (sesión + rol), `router` (go_router con redirect/guards por rol), `theme`, `main.dart`. |
| Archivos de contexto | Hecho | `CLAUDE.md`, este archivo, `ARQUITECTURA.md`, `API_CONTRATOS.md`. |
| Skills de Claude Code | Hecho | `new-screen`, `sync-api-models`, `feature-scaffold`. |
| CI + pre-commit | Hecho | `.github/workflows/ci.yml` (pub get → codegen → format → analyze → custom_lint → test); `scripts/pre-commit`. |
| Convenciones de código y UI | Definidas (2026-09-26) | `CLAUDE.md` §5: formato y análisis estático, modularización `core/` `features/` `shared/`, separación UI/lógica con Riverpod, design system, componentes compartidos, dartdoc y prohibición de emojis. |
| Design system y componentes compartidos | Pendiente | Reglas definidas en `CLAUDE.md` §5; falta crear `lib/shared/design_system/` y los componentes `Fletway*` en `lib/shared/widgets/`. Valores definidos (2026-10-01): primario naranja tostado `#C36224`, secundarios grises y fondo blanco (`ColorScheme.fromSeed`), tipografía Material 3 por defecto, radios 4/8/16/999. |
| Pantallas de negocio (Cliente / Transportista) | Pendiente | El router tiene solo `_Placeholder`. |
| Toolchain Android (SDK, emulador) | Pendiente | No instalado. No hace falta para analyze/test/codegen; sí para `flutter run`. |

---

## Pendientes / próximos pasos (ordenados)

El orden de trabajo lo marca `../fletway-backend/docs/PLAN_CONSTRUCCION.md` (backend y app avanzan
juntos, módulo a módulo). Lo propio de la app:

1. Completar `.env` real (`API_BASE_URL` con `/api`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`)
   desde el gestor de contraseñas del equipo.
2. **Módulo 1:** design system (`lib/shared/design_system/`, primario `#C36224`, grises y blanco) y
   componentes base `Fletway*` en `lib/shared/widgets/`.
3. **Módulo 2:** login y registro; `auth_controller` pasa a usar `GET /me` para rol y habilitación
   (resuelve el `TODO` actual).
4. **Módulos 3 en adelante:** pantallas según el mapa de `docs/ARQUITECTURA.md` §7, con
   `sync-api-models` a medida que el backend publica cada endpoint.
5. Paquetes a sumar cuando el módulo los necesite: `image_picker` y `file_picker` (módulo 3),
   `geolocator` ya está (módulo 10). Mapas y push quedan para después (M-08, M-10).
6. Elegir un logger.
7. Completar el dartdoc del código existente (por ejemplo `ApiClient`).
8. Para correr en emulador: Android Studio (instala el Android SDK) y
   `flutter doctor --android-licenses`.

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
| 2026-09-26 | Contexto alineado con la decisión D-13 del backend: no hay cotización estimada al publicar; el Cliente sólo ve el `precio_calculado` de cada oferta, sin desglose (`CLAUDE.md` §2 y §3, `API_CONTRATOS.md`, skills `new-screen` y `sync-api-models`). Convenciones de código y UI en `CLAUDE.md` §5. Emojis reemplazados por texto en este archivo. PR #1 mergeado; CI de `main` verde. |
| 2026-09-26 | Emoji quitado de la salida de `scripts/pre-commit`. PR #2 mergeado; CI de `main` verde. No quedan emojis en archivos versionados ni ramas secundarias. |
| 2026-10-01 | Definiciones para empezar la construcción: sólo Android, sin push en esta etapa, rol desde `GET /me`, dirección y mapa sin API por ahora, archivos con `image_picker`/`file_picker`, es-AR, comportamiento sin conexión (M-07 a M-13 en `ARQUITECTURA.md`), mapa de pantallas por rol (`ARQUITECTURA.md` §7), valores del design system, PIN que sólo ve el Cliente, score sin cercanía y contratos con prefijo `/api` (`API_CONTRATOS.md`). |
| 2026-10-01 | Color definido: primario naranja tostado `#C36224`, secundarios grises y fondo blanco. El alta de vehículo propone las medidas estándar del tipo elegido (D-32 del backend). |
