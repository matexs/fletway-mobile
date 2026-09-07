# fletway-mobile

App móvil en **Flutter** de **Fletway** (marketplace two-sided de fletes y mudanzas),
con **vistas diferenciadas Cliente / Transportista** en un mismo binario.
Proyecto final — Ingeniería en Sistemas de Información, UTN FRD.

La lógica de negocio y el contrato de la API viven en el repo **`fletway-backend`**
(fuente de verdad). Esta app consume esa API + Supabase para Auth y realtime.

## Stack

| Pieza | Elección |
|-------|----------|
| Framework | Flutter 3.24+ / Dart 3.5+ |
| Estado | `flutter_riverpod` |
| Navegación | `go_router` (guards por rol) |
| HTTP (backend Go) | `dio` + interceptor JWT |
| Auth + Realtime | `supabase_flutter` (GoTrue + Realtime sobre `mensaje` y `viaje_ubicacion`) |
| Geolocalización | `geolocator` (RI-04 / RN-06) |
| Modelos | `freezed` + `json_serializable` |

## Puesta en marcha

`flutter` no está incluido en el repo. Primera vez:

```bash
flutter create .                 # genera android/ ios/ web/ … sin tocar lib/ ni pubspec.yaml
cp .env.example .env             # completar SUPABASE_ANON_KEY y API_BASE_URL
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Estructura

```
lib/
  main.dart
  app/            App widget, router (go_router), theme
  core/           infra transversal
    config/       carga de .env
    network/      Dio + interceptor que inyecta el JWT en Authorization
    supabase/     cliente supabase_flutter (Auth + Realtime)
    auth/         sesión, usuario, rol (Cliente | Transportista)
    error/        Failure / manejo de errores de API
  shared/         widgets, modelos y extensiones compartidos entre roles
  features/
    auth/         login + registro (común)
    client/       features solo Cliente  (solicitudes, ofertas, viaje, perfil)
    carrier/      features solo Transportista (habilitación, ofertar, viaje, vehículo)
docs/             estado, arquitectura, mapa de contratos de API
.claude/          contexto y skills de Claude Code
```

Cada feature: `data/` (repos + DTOs) · `application/` (providers Riverpod) ·
`presentation/` (screens + widgets).

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [`CLAUDE.md`](CLAUDE.md) | Qué necesita saber esta app del backend/negocio (sin duplicar la ERS). |
| [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) | Patrón de estado/navegación, capas, realtime. |
| [`docs/API_CONTRATOS.md`](docs/API_CONTRATOS.md) | Mapa endpoint del backend → modelo/repo Dart. |
| [`docs/ESTADO_PROYECTO.md`](docs/ESTADO_PROYECTO.md) | Avance y pendientes. |

Fuente de verdad del contrato: `../fletway-backend/docs/ENDPOINTS.md`.

## Convenciones

- **Commits:** `feat(solicitud): pantalla de publicación [RF-06]`.
- **Branches:** `feat/RF-06-publicar-solicitud`.
- **Código:** `dart format` + `flutter analyze` limpio. Lógica de negocio nunca en
  `presentation/`. DTOs espejan los nombres de la API (español, snake_case).
