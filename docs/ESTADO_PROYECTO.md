# Estado del proyecto — fletway-mobile

> Foto viva del avance. Actualizar al cerrar cada bloque. Fechas absolutas.

**Última actualización:** 2026-10-02 · **Etapa:** construcción; módulo 1 (design system y componentes base) terminado

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
| `build_runner` | Hecho | Corre OK. Primer modelo `freezed`: `Me` (`shared/models/me.dart`). Lo generado no se versiona (lo regenera el CI). |
| Esqueleto `lib/core/` + `lib/app/` | Hecho | `env` (con `SUPABASE_PUBLISHABLE_KEY` + fallback `SUPABASE_ANON_KEY`), `api_client` (Dio + `AuthInterceptor` con JWT de Supabase), `supabase_client` (Auth+Realtime, PKCE), `auth` (sesión + rol), `router` (go_router con redirect/guards por rol), `theme`, `main.dart`. |
| Archivos de contexto | Hecho | `CLAUDE.md`, este archivo, `ARQUITECTURA.md`, `API_CONTRATOS.md`. |
| Skills de Claude Code | Hecho | `new-screen`, `sync-api-models`, `feature-scaffold`. |
| CI + pre-commit | Hecho | `.github/workflows/ci.yml` (pub get → codegen → format → analyze → custom_lint → test); `scripts/pre-commit`. |
| Convenciones de código y UI | Definidas (2026-09-26) | `CLAUDE.md` §5: formato y análisis estático, modularización `core/` `features/` `shared/`, separación UI/lógica con Riverpod, design system, componentes compartidos, dartdoc y prohibición de emojis. |
| Design system y componentes compartidos | Hecho (2026-10-02, módulo 1) | Tokens en `lib/shared/design_system/` (primario `#C36224`, grises, fondo blanco), tema claro y oscuro en `theme.dart`, y `FletwayButton`, `FletwayTextField`, `FletwayCard` y las vistas de carga, error y vacío, con widget tests. Faltan `FletwayConfirmDialog` y las variantes numérica y de selector del campo, que se suman cuando una pantalla las necesite. |
| Identidad (módulo 2) | Hecho (2026-10-02) | Login, registro de Cliente y de Transportista (una pantalla por rol) y pantalla de inicio (carga del perfil, error con reintento). `AuthController` toma el rol de `GET /me` y completa el registro si falta la fila del rol. Guards del router en `resolverRedireccion` (función pura, con tests). Probado en el emulador y mergeado. |
| Habilitación (módulo 3) | Hecho (2026-10-03) | Pantalla "Mi documentación": estado de habilitación y carga de DNI, registro, seguro y VTV desde cámara, galería o archivo (`image_picker`, `file_picker`), con el motivo y "Volver a cargar" si se rechaza (D-33). Es el inicio del Transportista no habilitado; el habilitado la abre desde su inicio. Falta probarla en el emulador. |
| Vehículos, costos y zonas (módulo 4) | Hecho (2026-10-03) | Inicio del Transportista habilitado con el interruptor de disponibilidad; mis vehículos (activar o desactivar); alta con el tipo que propone medidas estándar (D-32); zonas de trabajo agrupadas por provincia. El no habilitado llega a vehículos y zonas desde su documentación. Componentes nuevos: `FletwayTextField.decimal` y `FletwaySelector`. Probado en el emulador y mergeado. La pantalla de costos se retiró en el módulo 8 (D-34). |
| Catálogo de objetos (módulo 5) | Hecho (2026-10-03) | Selector del catálogo con buscador e íconos por objeto, dentro de la feature de solicitudes. Probado en el emulador y mergeado. |
| Solicitud (módulo 6) | Hecho (2026-10-03) | Inicio del Cliente con sus solicitudes (estado con ícono y color); publicar (origen y destino con acceso, fecha y franja, objetos del catálogo o a mano con cantidades, ayudantes, sin ningún precio); detalle con cancelar (con confirmación) y republicar si venció. Fechas en es-AR (`flutter_localizations`). Probado en el emulador. |
| Matchmaking (módulo 7) | Hecho (2026-10-03) | "Solicitudes en tus zonas" desde el inicio del Transportista: listado de compatibles (el filtro lo hace el backend, D-21) con fecha, carga y ayudantes, sin montos, y detalle con direcciones, acceso y objetos. El detalle de solicitud y los íconos de objetos pasaron a `shared`. Probado en el emulador. |
| Oferta (módulo 8) | Hecho (2026-10-03) | "Armar oferta" desde el detalle de una solicitud compatible: elegir vehículo (los inactivos se explican) y ayudantes; cada cambio cotiza sin guardar y muestra precio, viajes y desglose plegado, o por qué la carga no entra. Confirmación antes de enviar. "Mis ofertas" desde el inicio: estado, precio, desglose y retiro de las pendientes. Probado en el emulador. |
| Elección de oferta (módulo 9) | Hecho en código (2026-10-03) | En el detalle de una solicitud publicada: ofertas ordenadas por score con la recomendada arriba, reputación ("Nuevo en Fletway" sin reseñas), ayudantes contra los pedidos, "ver más" y elegir con confirmación. Perfil público del Transportista (cómo trabaja, reputación, zonas, vehículos y reseñas). Al aceptar, pantalla de viaje confirmado con la patente. |
| Pantallas de negocio (Cliente / Transportista) | Pendiente | Los inicios de cada rol siguen siendo `_Placeholder` (con "Cerrar sesión"). |
| Entorno local de la app | Hecho (2026-10-02) | `.env.example` apunta a Supabase local (`10.0.2.2:54321`, D-16). Permiso `INTERNET` en el manifest principal (faltaba) y HTTP sin TLS sólo en debug. |
| Toolchain Android (SDK, emulador) | Pendiente | No instalado. No hace falta para analyze/test/codegen; sí para `flutter run`. |

---

## Pendientes / próximos pasos (ordenados)

El orden de trabajo lo marca `../fletway-backend/docs/PLAN_CONSTRUCCION.md` (backend y app avanzan
juntos, módulo a módulo). Lo propio de la app:

1. Completar `.env` real (`API_BASE_URL` con `/api`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`)
   desde el gestor de contraseñas del equipo.
2. ~~**Módulo 1:** design system y componentes base.~~ **Hecho 2026-10-02.**
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
| 2026-10-02 | Módulo 1: design system y componentes base. Verificado con Flutter 3.47.6: `dart format`, `flutter analyze`, `custom_lint` y 13 tests en verde. |
| 2026-10-02 | Módulo 2: login, registro y rol desde `GET /me`; guards del router. `dart format`, `flutter analyze`, `custom_lint` y 58 tests en verde. |
| 2026-10-03 | Módulo 2 probado en el emulador (arreglos de navegación y validación). Módulo 3: documentación del Transportista. `analyze`, `custom_lint` y 72 tests en verde. |
| 2026-10-03 | Módulo 3 probado en el emulador (arreglo: el pendiente volvía a su inicio con la flecha). Módulo 4: vehículos, costos, zonas y disponibilidad. `analyze`, `custom_lint` y 88 tests en verde. |
| 2026-10-03 | Módulo 5 probado y mergeado. Decoración mínima por pantalla hasta el módulo 15 (`CLAUDE.md`); íconos en el catálogo. Módulo 6: publicación y seguimiento de solicitudes; `FletwayConfirmDialog` y `FletwaySeccion`. 115 tests en verde. |
| 2026-10-03 | Módulo 6 probado en el emulador (arreglo: el teclado se abría solo al cerrar diálogos) y mergeado. Módulo 7: solicitudes compatibles del Transportista. 117 tests en verde. |
| 2026-10-03 | Módulo 7 mergeado. Módulo 8: armar oferta con cotización previa y mis ofertas. 124 tests en verde. |
| 2026-10-03 | D-34 del backend: los costos del vehículo son de referencia por tipo, definidos por la plataforma. Se retiran la pantalla de costos, `CostosVehiculo` y `tiene_costos`; el alta de vehículo es de un solo paso. 123 tests en verde. |
| 2026-10-03 | Módulo 8 mergeado. Módulo 9: ofertas del Cliente ordenadas por score, perfil del Transportista y aceptación con viaje confirmado. 129 tests en verde. |
