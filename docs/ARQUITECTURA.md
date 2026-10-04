# Arquitectura — fletway-mobile

**Última actualización:** 2026-10-01

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
| M-07 | **Sólo Android** en esta etapa | iOS requiere Mac y APNs (D-17 del backend). `ios/` queda generado sin mantenerse. |
| M-08 | **Sin notificaciones push** en esta etapa; avisos in-app (`GET /notificaciones`) | D-17/D-22 del backend. Se suman después con FCM (`firebase_messaging`). |
| M-09 | **Rol y habilitación desde `GET /me`**, nunca desde `user_metadata` | La metadata la puede editar el propio usuario (D-18 del backend). |
| M-10 | **Dirección, mapa y geocodificación sin API** por ahora: dirección manual + selector de zona; el mapa (`google_maps_flutter`) y la geocodificación se integran después | D-17/D-20 del backend. Los componentes se arman detrás de una interfaz para conectar el proveedor sin rehacer pantallas. |
| M-11 | Archivos con **`image_picker`** y **`file_picker`** (jpg, png, pdf; hasta 10 MB) | Documentos del Transportista e incidentes (D-19 del backend). |
| M-12 | **Sólo español (Argentina)**, sin internacionalización; `intl` con locale `es_AR` para moneda y fechas | D-17 del backend. |
| M-13 | **Sin conexión:** el PIN requiere red (reintento automático con aviso); los pings de GPS se encolan y se reenvían al volver la señal | D-26 del backend. |

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
| `auth/` | `AppUser` (id, email, **rol**: `cliente` \| `transportista`, estado de habilitación), `AuthRepository` (login, registro, logout, refresh vía GoTrue), `authControllerProvider` (estado de sesión observado por el router). El rol y la habilitación salen de `GET /me` (M-09). |
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

---

## 7. Mapa de pantallas por rol

Derivado de los RF y del plan de construcción (`../fletway-backend/docs/PLAN_CONSTRUCCION.md`). La columna "Mód." es el módulo del plan en el que se construye cada pantalla. Rutas bajo `/cliente/...` y `/transportista/...` según M-02.

**Comunes**

| Pantalla | RF | Mód. |
|---|---|---|
| Login | — | 2 |
| Registro de Cliente | RF-05 | 2 |
| Registro de Transportista (datos personales) | RF-16 | 2 |
| Notificaciones (in-app) | RF-09 | 13 |
| Perfil propio | — | 2 |

**Cliente**

| Pantalla | RF | Mód. |
|---|---|---|
| Home (mis solicitudes y viajes activos) | — | 6 |
| Publicar solicitud: zonas, dirección, fecha y franja, acceso (pisos, ascensor, distancia a pie), objetos del catálogo o manuales, ayudantes deseados | RF-06 | 6 |
| Detalle de solicitud: top 3 de ofertas y "ver más"; cancelar; republicar si venció | RF-06, RF-07 | 6, 9 |
| Perfil del Transportista (reseñas, calificación, cumplimiento) | RF-11 | 9 |
| Viaje: PIN de inicio y de fin visibles, seguimiento, chat, cancelar con aviso de cargo | RF-08, RF-10, RF-15 | 10, 11 |
| Calificar el servicio | RF-12 | 13 |
| Reportar un problema | RF-13 | 13 |
| Historial de viajes | RF-14 | 14 |

**Transportista**

| Pantalla | RF | Mód. |
|---|---|---|
| Estado de habilitación y carga de documentos | RF-01, RF-16 | 3 |
| Mis vehículos: alta (elige el tipo, la app propone sus medidas estándar y el Transportista las corrige con las reales; peso) (los costos del vehículo son de referencia por tipo, D-34) | RF-18 | 4 |
| Mis zonas de trabajo y disponibilidad | RN-04 | 4 |
| Solicitudes compatibles y detalle | RF-17 | 7 |
| Armar oferta (vehículo y ayudantes; ver precio y viajes, o el motivo si la carga no entra) | RF-17 | 8 |
| Mis ofertas (retirar) | RF-17 | 8 |
| Viaje: "salí", carga de PIN de inicio y de fin, envío de ubicación, chat, cancelar | RF-19, RF-20, RF-21, RF-22 | 10, 11 |
| Vincular cuenta de Mercado Pago | RI-03 | 12 |
| Reportar un problema | RF-23 | 13 |
| Historial de viajes | RF-24 | 14 |

