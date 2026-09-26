# CLAUDE.md — fletway-mobile

> Contexto persistente del repo de la **app móvil Flutter** de Fletway.
> Cualquier sesión de Claude Code debe poder arrancar leyendo **solo este archivo**
> + `docs/ESTADO_PROYECTO.md` + `docs/ARQUITECTURA.md`.

---

## 1. Rol del agente en este repo

Sos el agente de desarrollo de la **app móvil** (Flutter) de Fletway, con **vistas
diferenciadas para Cliente y Transportista** en un mismo binario (RI-02).

Este repo **consume**; no define negocio. La **fuente de verdad** es el repo
**`fletway-backend`**:

- Requisitos (ERS): `fletway-backend/docs/ERS_Fletway.pdf`
- Esquema de datos: `fletway-backend/docs/DOCUMENTACION_BASE_DE_DATOS.md`
- Contrato de API: `fletway-backend/docs/ENDPOINTS.md` ← lo que consume esta app
- Reglas de negocio y trazabilidad: `fletway-backend/CLAUDE.md` §3 y `docs/TRAZABILIDAD.md`

No dupliques la ERS acá. Si necesitás el detalle de un RF/RN, andá al backend.

Lo que **no** se hace en este repo:

- No hay web admin / Angular (fuera de alcance de toda la etapa).
- No se reimplementa lógica de negocio del backend (cotización, score, comisión,
  validación de PIN): eso llega calculado desde la API.
- No se inventan endpoints ni campos: si falta algo en `fletway-backend/docs/ENDPOINTS.md`,
  se pide/coordina con el backend.

---

## 2. El negocio en 5 líneas

Fletway conecta **Clientes** que necesitan trasladar objetos con **Transportistas**
("fleteros") verificados. El Cliente publica una **solicitud** (sin ningún precio) y el
sistema notifica a Transportistas compatibles por zona/vehículo. Cada Transportista se
**postula** con una **oferta** (modelo *pull*), cuyo precio calcula el backend con el vehículo
y los ayudantes reales de ese Transportista. El Cliente ve un
**top 3 por score** y elige: se confirma un **viaje** que se ejecuta con **PIN de
inicio y fin + GPS**, se paga con **comisión de plataforma**, y el Cliente deja una
**reseña**. El **chat** se habilita solo tras confirmar el viaje.

---

## 3. Qué necesita esta app del backend / negocio

### 3.1 Consumo de la API (modelo híbrido)

| Canal | Qué va por acá |
|-------|----------------|
| **Backend Go** (`API_BASE_URL`, REST + JWT en todos los endpoints — RNF-01) | Registro (RF-05, RF-16), vehículos (RF-18), publicar solicitud (RF-06, sin precio), ver/ofertar con precio y viajes calculados (RF-17 / RN-01 / RN-02), elegir oferta / confirmar viaje (RF-07), cancelaciones (RF-08 / RF-19 / RN-07), info e historial de viajes (RF-14, RF-21, RF-24), PIN inicio/fin (RF-22 / RN-06), reseña (RF-12), perfiles (RF-11), incidentes (RF-13, RF-23), notificaciones (RF-09). |
| **Supabase directo** (`supabase_flutter`, apoyado en RLS) | **Auth** (GoTrue: login, registro de credenciales, refresh, `auth.uid()` = `usuario.id`). **Realtime:** chat sobre `mensaje` (RF-10 / RF-20 / RI-05), ubicación en vivo sobre `viaje_ubicacion` (RF-15 / RI-04). El Transportista **inserta** sus pings GPS en `viaje_ubicacion`; el Cliente los **lee**. |

> El JWT lo emite Supabase Auth y se manda **tanto** a Supabase como en el header
> `Authorization: Bearer` de cada request al backend Go. Un solo token, dos consumidores.

### 3.2 RF relevantes por rol

**Cliente:** RF-05 a RF-15.
**Transportista:** RF-16 a RF-24.
**Ambos:** RF-09 (notificaciones), RF-10/RF-20 (chat), historial.
**Administrador (RF-01 a RF-04):** NO tiene app móvil — es la futura web admin. Ignorar.

### 3.3 Reglas de negocio que la UI debe respetar (detalle en el backend)

- **RN-01 / RNF-04 — mínima decisión del Cliente:** **no hay cotización estimada** al
  publicar la solicitud (decisión D-13 del backend). El único precio que ve el Cliente es el
  `precio_calculado` de cada oferta, tal como lo devuelve la API: no se edita ni se recalcula.
  El Cliente nunca tipea un precio, y nunca se le muestra el desglose de costo de la oferta.
- **RN-05 — top 3:** por defecto se muestran **3** ofertas ordenadas por score; botón
  "ver más" para pedir el resto. No mostrar todas de una.
- **RN-06 — flujo de PIN:** el Transportista ve/carga **PIN de inicio** al llegar a
  cargar y **PIN de fin** al terminar; ambos van al backend junto con la ubicación
  GPS. La pantalla de **reseña** del Cliente se habilita recién cuando el viaje quedó
  finalizado (PIN de fin validado por el backend).
- **RN-07 — cancelación:** al cancelar, la UI del Cliente debe advertir si hay **cargo
  de resarcimiento** (si el Transportista ya salió) vs sin cargo. El backend decide el
  monto; la app solo informa y confirma.
- **RI-05 — chat:** la entrada al chat aparece **solo** cuando existe un viaje
  confirmado. Sin viaje, no hay chat.
- **RF-17 / RN-04:** el Transportista solo ve solicitudes compatibles con su zona y
  vehículo; el filtrado lo hace el backend/RLS, la app no reimplementa el matching.
- Solo un Transportista **habilitado** puede ofertar (RF-01). Si está `pendiente` o
  `rechazado`, la UI muestra el estado de habilitación y bloquea "ofertar".

---

## 4. Arquitectura (resumen — detalle en `docs/ARQUITECTURA.md`)

- **Estado:** `flutter_riverpod` (providers + `AsyncValue`; `StreamProvider` para el
  realtime de Supabase).
- **Navegación:** `go_router` declarativo, con **redirect/guards por rol**
  (no-auth → login; Cliente y Transportista tienen árboles de rutas separados).
- **Capas por feature** (feature-first):
  ```
  lib/features/<area>/<feature>/
    data/          repositorios + DTOs (mapear contra fletway-backend/docs/ENDPOINTS.md)
    application/   providers/controllers Riverpod (estado de UI, orquestación)
    presentation/  screens + widgets
  ```
- **`lib/core/`** infra transversal: `config` (env), `network` (Dio + interceptor JWT),
  `supabase` (cliente Auth/Realtime), `auth` (sesión + rol), `error`.
- **`lib/shared/`** widgets, modelos y extensiones compartidos entre Cliente y Transportista.
- **`lib/features/auth/`** login y registro (común). **`lib/features/client/`** solo
  Cliente. **`lib/features/carrier/`** solo Transportista.

---

## 5. Convenciones

### Commits (Conventional Commits + ref a requisito)

```
<tipo>(<scope>): <resumen imperativo>   [RF-XX]
```

- `tipo` ∈ `feat` `fix` `refactor` `test` `docs` `chore` `build` `ci`.
- `scope` = feature o área (`auth`, `solicitud`, `oferta`, `viaje-cliente`,
  `viaje-carrier`, `chat`, `tracking`, `core`).
- Citar el RF entre corchetes: `feat(solicitud): pantalla de publicación [RF-06]`.

### Branches

`<tipo>/<RF>-<slug>` — ej. `feat/RF-06-publicar-solicitud`,
`feat/RF-22-pin-viaje`, `fix/RF-07-top3-orden`.

### Código Dart

- `dart format` + `flutter analyze` limpio (config en `analysis_options.yaml`).
- Providers Riverpod: un archivo por provider/controller en `application/`.
- Nada de lógica de negocio en `presentation/`: la screen observa providers y renderiza.
- DTOs en `data/` con `freezed` + `json_serializable`; los nombres de campos JSON
  **espejan la API** (español, snake_case) — ver skill `sync-api-models`.
- Sin `print` (usar el logger); sin llamadas HTTP fuera de `data/`.

---

## 6. Skills disponibles (`.claude/skills/`)

| Skill | Cuándo usarla |
|-------|---------------|
| `new-screen` | Crear una pantalla nueva con el patrón estado/navegación del repo (feature-first, Riverpod `AsyncValue`, ruta `go_router` con guard de rol). |
| `sync-api-models` | Mantener los DTOs/modelos Dart en sincronía con `fletway-backend/docs/ENDPOINTS.md` (fuente de verdad del contrato). Correr cuando el backend avise que cambió el contrato. |
| `feature-scaffold` | Crear la carpeta completa de una feature nueva (`data/ application/ presentation/`) con los archivos base. |

---

## 7. Estado del toolchain

Flutter **3.47.2 / Dart 3.13.2** instalado en `C:\src\flutter`. El proyecto ya
tiene `android/` + `ios/`, `pub get` corrido, `flutter analyze` sin issues y
`build_runner` operativo. Versiones clave: **Riverpod 3**, **go_router 18**,
**freezed 3** (clases `abstract class X with _$X`). El **Android SDK / emulador
NO** está instalado — hace falta solo para `flutter run` en dispositivo, no para
analyze / test / codegen. Detalle y próximos pasos en `docs/ESTADO_PROYECTO.md`.
