# Arquitectura — fletway-mobile

**Última actualización:** 2026-09-07

Patrón de referencia para toda la app. Las skills `new-screen` y `feature-scaffold`
lo aplican.

---

## 1. Decisiones (acordadas)

| # | Decisión | Motivo |
|---|----------|--------|
| M-01 | Estado con **`flutter_riverpod`** (sin codegen de riverpod por ahora) | Menos boilerplate; `AsyncValue` calza con consumo de API y streams de realtime. |
| M-02 | Navegación con **`go_router`** declarativo + `redirect` por rol | Cliente y Transportista tienen árboles de ruta separados; guard central de auth. |
| M-03 | **Feature-first**: `lib/features/<area>/<feature>/{data,application,presentation}` | Escala mejor que layer-first cuando hay dos roles con features propias. |
| M-04 | HTTP al backend Go con **`dio`** + interceptor que inyecta el JWT | RNF-01: todos los endpoints del backend requieren `Authorization: Bearer`. |
| M-05 | **`supabase_flutter`** para Auth y Realtime, no para CRUD de negocio | Modelo híbrido (ver `fletway-backend/docs/DECISIONES_TECNICAS.md` D-10). |
| M-06 | DTOs con **`freezed` + `json_serializable`**, campos espejando la API | Contrato estable; ver skill `sync-api-models`. |

---

## 2. Capas por feature

```
lib/features/<area>/<feature>/
├── data/
│   ├── <feature>_dto.dart          # freezed + json_serializable; espeja la API
│   └── <feature>_repository.dart   # llama a ApiClient (Dio) o al canal Supabase
├── application/
│   ├── <feature>_controller.dart   # AsyncNotifier / Notifier: estado + acciones
│   └── <feature>_providers.dart    # Provider(s) de repos y de estado derivado
└── presentation/
    ├── <feature>_screen.dart       # observa providers, renderiza, dispara acciones
    └── widgets/                    # widgets propios de la pantalla
```

Reglas:

- **`presentation/` no tiene lógica de negocio ni HTTP.** Observa un provider y
  llama métodos del controller.
- **`data/` es el único lugar con llamadas de red.** Un repo devuelve modelos del
  dominio o lanza `ApiException` (ver `core/network`).
- El **controller** (`application/`) traduce respuestas/errores a estado de UI
  (`AsyncValue`, estados `freezed` sellados si el flujo lo amerita).

---

## 3. `lib/core/` — infra transversal

| Carpeta | Contenido |
|---------|-----------|
| `config/` | `Env` — carga `.env` (`API_BASE_URL`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` (o `SUPABASE_ANON_KEY`), `APP_ENV`). |
| `network/` | `ApiClient` (Dio configurado) + `AuthInterceptor` (agrega el JWT de la sesión Supabase a cada request) + `ApiException` (mapea el envelope de error único del backend `{error:{code,message}}`). |
| `supabase/` | `SupabaseInit` / `supabaseClient` — inicializa `supabase_flutter`; expone helpers de streams para `mensaje` y `viaje_ubicacion`. |
| `auth/` | `AppUser` (id, email, **rol**: `cliente` \| `transportista`), `AuthRepository` (login, registro, logout, refresh vía GoTrue), `authControllerProvider` (estado de sesión observado por el router). |
| `error/` | `Failure` + helpers de presentación de errores. |

---

## 4. Navegación y guards (`app/router.dart`)

- `redirect` global:
  - sin sesión y ruta protegida → `/login`.
  - con sesión: según `AppUser.rol`, raíz `/cliente/...` o `/transportista/...`.
  - rol Cliente intentando entrar a `/transportista/...` (o viceversa) → redirige a su home.
- Rutas de chat/tracking **solo existen bajo un `viaje/:id`** confirmado (RI-05).
- El router observa `authControllerProvider` (via `refreshListenable`) para
  re-evaluar en login/logout.

---

## 5. Realtime (Supabase directo)

| Feature | Tabla | Dirección | Provider |
|---------|-------|-----------|----------|
| Chat (RF-10 / RF-20) | `mensaje` | Cliente y Transportista del viaje: leen y escriben | `StreamProvider.family<List<Mensaje>, ViajeId>` |
| Ubicación en vivo (RF-15 / RI-04) | `viaje_ubicacion` | Transportista **inserta** pings (`geolocator`); Cliente **lee** | `StreamProvider.family` (Cliente) / servicio de envío periódico (Transportista) |

RLS es la autorización de estos canales — la app no filtra por seguridad, solo por UX.
Antes de habilitarlos, el backend corre su skill `rls-policy-review` sobre esas tablas.

---

## 6. Testing

- `test/` espeja `lib/`. Unit test de controllers con `mocktail` sobre los repos.
- Golden/widget test para pantallas clave (top 3 ofertas, flujo de PIN).
- Sin llamadas de red reales en tests.
