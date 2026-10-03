# CLAUDE.md — fletway-mobile

> Contexto persistente del repo de la **app móvil Flutter** de Fletway.
> Cualquier sesión de Claude Code debe poder arrancar leyendo **solo este archivo**
> + `docs/ESTADO_PROYECTO.md` + `docs/ARQUITECTURA.md`. El orden de construcción (backend y app,
> módulo a módulo) está en `../fletway-backend/docs/PLAN_CONSTRUCCION.md`.

---

## 1. Rol del agente en este repo

Sos el agente de desarrollo de la **app móvil** (Flutter) de Fletway, con **vistas
diferenciadas para Cliente y Transportista** en un mismo binario (RI-02).

Este repo **consume**; no define negocio. La **fuente de verdad** es el repo
**`fletway-backend`**:

- Requisitos (ERS): `fletway-backend/docs/ERS_Fletway.docx`
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
| **Backend Go** (`API_BASE_URL`, que ya incluye el prefijo `/api`; REST + JWT en todos los endpoints — RNF-01) | Perfil y rol (`GET /me`), registro (RF-05, RF-16), vehículos (RF-18), publicar solicitud (RF-06, sin precio), ver/ofertar con precio y viajes calculados (RF-17 / RN-01 / RN-02), elegir oferta / confirmar viaje (RF-07), cancelaciones (RF-08 / RF-19 / RN-07), info e historial de viajes (RF-14, RF-21, RF-24), PIN inicio/fin (RF-22 / RN-06), reseña (RF-12), perfiles (RF-11), incidentes (RF-13, RF-23), notificaciones (RF-09). |
| **Supabase directo** (`supabase_flutter`, apoyado en RLS) | **Auth** (GoTrue: login, registro de credenciales, refresh, `auth.uid()` = `usuario.id`). **Realtime:** chat sobre `mensaje` (RF-10 / RF-20 / RI-05), ubicación en vivo sobre `viaje_ubicacion` (RF-15 / RI-04). El Transportista **inserta** sus pings GPS en `viaje_ubicacion`; el Cliente los **lee**. |

> El JWT lo emite Supabase Auth y se manda **tanto** a Supabase como en el header
> `Authorization: Bearer` de cada request al backend Go. Un solo token, dos consumidores.

### 3.2 RF relevantes por rol

**Cliente:** RF-05 a RF-15.
**Transportista:** RF-16 a RF-24.
**Ambos:** RF-09 (notificaciones), RF-10/RF-20 (chat), historial.
**Administrador (RF-01 a RF-04):** NO tiene app móvil. En esta etapa opera con endpoints del
backend desde Postman (D-17 del backend). Ignorar.

### 3.3 Reglas de negocio que la UI debe respetar (detalle en el backend)

- **RN-01 / RNF-04 — mínima decisión del Cliente:** **no hay cotización estimada** al
  publicar la solicitud (decisión D-13 del backend). El único precio que ve el Cliente es el
  `precio_calculado` de cada oferta, tal como lo devuelve la API: no se edita ni se recalcula.
  El Cliente nunca tipea un precio, y nunca se le muestra el desglose de costo de la oferta.
- **RN-05 — top 3:** por defecto se muestran **3** ofertas ordenadas por el score que calcula
  el backend (precio, calificación y tasa de cumplimiento; **sin cercanía**, D-25); botón
  "ver más" para pedir el resto. No mostrar todas de una. La patente del vehículo se muestra
  recién después de aceptar.
- **RN-05 — avisos:** en esta etapa **no hay notificaciones push** (D-17). Los avisos son
  notificaciones in-app (RF-09) y el Transportista ve el listado de solicitudes compatibles.
- **RN-06 — flujo de PIN (D-26):** el **Transportista nunca ve el PIN**. El Cliente ve el PIN
  de inicio y el de fin en su pantalla del viaje y se los dicta al Transportista: el de inicio
  antes de empezar el servicio y el de fin al terminar. La pantalla del Transportista sólo tiene
  el campo para cargarlo; el valor viaja al backend con la ubicación GPS. La pantalla de
  **reseña** del Cliente se habilita cuando el viaje quedó finalizado (PIN de fin validado), y
  durante 14 días.
- **RN-07 — cancelación:** el Transportista marca "salí" al salir hacia el origen. Al cancelar,
  la UI del Cliente advierte si hay **cargo de resarcimiento** (20 % del precio, si el
  Transportista ya salió) o no. El backend decide el monto; la app sólo informa y confirma.
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
- Subject en imperativo, en español, con minúscula inicial, sin punto final y de hasta ~72
  caracteres. El cuerpo explica **por qué** se hizo el cambio.
- Un commit = una unidad lógica. No mezclar formato, refactor y feature en el mismo commit.
- **Sin emojis** en el subject ni en el cuerpo (ver "Prohibición de emojis").

### Branches

`<tipo>/<RF>-<slug>` — ej. `feat/RF-06-publicar-solicitud`,
`feat/RF-22-pin-viaje`, `fix/RF-07-top3-orden`.

### Formato y análisis estático

- **`dart format` obligatorio.** El CI rechaza código sin formatear
  (`dart format --output=none --set-exit-if-changed lib test`). El formateador de Dart 3.7+
  maneja las comas finales; por eso `require_trailing_commas` no está activa.
- **`flutter analyze` sin issues**, con `analysis_options.yaml`: `flutter_lints` más
  `always_declare_return_types`, `avoid_print`, `prefer_const_constructors`,
  `prefer_const_declarations`, `prefer_final_locals`, `unawaited_futures`,
  `use_key_in_widget_constructors` y `directives_ordering`.
- **`dart run custom_lint`** sin hallazgos (reglas de `riverpod_lint`).
- **Antes de cada commit** corre el hook `scripts/pre-commit` (format, analyze, custom_lint y
  test; lo mismo que el CI). Instalar con
  `cp scripts/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit`.
- Un `// ignore:` sólo para una regla concreta y con un comentario que explique el motivo.
  Nunca `// ignore_for_file:` para esquivar el análisis, ni desactivar reglas en
  `analysis_options.yaml`.
- El código generado (`*.g.dart`, `*.freezed.dart`) no se edita a mano: se regenera con
  `dart run build_runner build`.

### Modularización por feature

```
lib/
  main.dart
  app/            MaterialApp, router (go_router + guards por rol) y theme.dart
  core/           infra transversal sin UI de negocio: config, network, supabase, auth, error
  shared/         lo que usan Cliente y Transportista
    design_system/  tokens: colores, tipografía, espaciados, radios
    widgets/        componentes homologados (único set de UI reutilizable)
    models/         DTOs compartidos (sync-api-models)
    extensions/     extensiones sobre tipos base (moneda, fechas)
  features/
    auth/                 login y registro (común)
    client/<feature>/     sólo Cliente
    carrier/<feature>/    sólo Transportista
      data/ application/ presentation/   (detalle en docs/ARQUITECTURA.md §2)
```

Reglas de dependencia:

- `core/` no importa nada de `features/`.
- `shared/` no importa nada de `features/`.
- Una feature no importa otra feature. Lo que dos features necesitan sube a `shared/`.
- `client/` y `carrier/` no se importan entre sí.
- Features nuevas con la skill `feature-scaffold`; pantallas nuevas con `new-screen`.

### Pantallas: separación entre UI y lógica

Estado con Riverpod (M-01). Cada capa tiene una sola responsabilidad:

| Capa | Hace | No hace |
|---|---|---|
| `presentation/` | Renderiza. La screen es un `ConsumerWidget` (o `ConsumerStatefulWidget` si necesita controllers de texto o animación), observa con `ref.watch` y dispara acciones con `ref.read(xxxControllerProvider.notifier).accion()`. | Llamadas HTTP o Supabase, reglas de negocio, cálculos (precio, viajes, score: llegan calculados del backend), parseo de JSON. |
| `application/` | Controllers `AsyncNotifier` / `Notifier` y providers, un archivo por provider/controller. Orquesta llamadas al repo y traduce resultados y errores a estado de UI (`AsyncValue`). | Widgets, `BuildContext`, navegación. |
| `data/` | Única capa con red: repositorios que usan `ApiClient` o el canal Supabase. DTOs con `freezed` + `json_serializable`, con campos que **espejan la API** (español, snake_case; skill `sync-api-models`). | Estado de UI, widgets. |

- Los estados de carga, error y vacío se resuelven con `AsyncValue.when` y los componentes de
  estado de `shared/widgets/`, nunca con widgets armados a mano en la pantalla.
- Archivos de una pantalla: `<feature>_screen.dart`. Sus partes propias van en
  `presentation/widgets/` y se componen **sólo** con componentes de `shared/widgets/`.
- Rutas en `lib/app/router.dart`, con guard de rol (M-02).
- Sin `print` (lo exige `avoid_print`). Todavía no hay un logger elegido: es un pendiente. Hasta
  que exista, la UI no loguea.

### Design system

Los valores visuales se definen **una sola vez**, como tokens en `lib/shared/design_system/`, y
el resto de la app los consume desde ahí o desde el `Theme`.

| Token | Archivo | Contenido |
|---|---|---|
| Colores | `fletway_colors.dart` | Clase `FletwayColors`. Colores por **rol semántico** (primario, secundario, superficie, error, éxito, advertencia, texto), nunca por nombre de color. |
| Tipografía | `fletway_typography.dart` | Clase `FletwayTypography`. Familia tipográfica y escala mapeada al `TextTheme` de Material 3 (`displayLarge` … `labelSmall`). |
| Espaciados | `fletway_spacing.dart` | Clase `FletwaySpacing`. Escala base 4: `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `xxl` 32, `xxxl` 48. |
| Radios | `fletway_radius.dart` | Clase `FletwayRadius`: `sm`, `md`, `lg`, `full`. |

- **Valores (provisionales y reemplazables):**
  - **Paleta (A-2 del plan, 2026-10-01):** el color de marca es un **naranja tostado,
    amarronado: `#C36224`**, usado como **primario** (botones principales, acentos, estados
    activos). El resto es discreto: **secundarios en grises** neutros y **fondo blanco**.
    Implementación: `ColorScheme.fromSeed(seedColor: Color(0xFFC36224))` con una variante que
    respete el tono de la semilla en el primario (por ejemplo `DynamicSchemeVariant.fidelity`), y
    `secondary`/`tertiary` sobrescritos con grises neutros y `surface` en blanco para el tema claro.
    En el tema oscuro, la misma semilla con superficies en gris oscuro. Los valores exactos de
    los grises se fijan una sola vez en `fletway_colors.dart`. La semilla anterior (`#1B6EF3`, azul)
    queda descartada.
  - **Tipografía:** la escala por defecto de Material 3, sin fuente propia.
  - **Radios:** `sm` 4, `md` 8, `lg` 16, `full` 999.
  - **Modo oscuro:** sí, con la misma semilla y `Brightness.dark`.
- `lib/app/theme.dart` es el **único** lugar que traduce los tokens a `ThemeData` (claro y
  oscuro, desde los mismos tokens). Los colores sin equivalente en `ColorScheme` (éxito,
  advertencia) se exponen con un `ThemeExtension`.
- En widgets, los colores y estilos de texto se leen del tema
  (`Theme.of(context).colorScheme`, `Theme.of(context).textTheme`) y los espaciados y radios de
  `FletwaySpacing` / `FletwayRadius`.
- **Prohibido fuera de `lib/shared/design_system/` y `lib/app/theme.dart`:** literales de color
  (`Color(0x...)`, `Colors.xxx`), `TextStyle(fontSize: ...)`, paddings, gaps o radios numéricos
  (`EdgeInsets.all(13)`, `SizedBox(height: 10)`, `BorderRadius.circular(6)`).
- Estado actual: implementado (módulo 1). Tokens en `lib/shared/design_system/` (importar
  `design_system.dart`) y tema en `lib/app/theme.dart`; los colores de estado se leen con
  `Theme.of(context).extension<FletwayEstados>()!`.

### Componentes compartidos

- Hay **un único set** de componentes de UI reutilizables, en `lib/shared/widgets/`. Todos llevan
  el prefijo `Fletway`:
  - **Botones:** `FletwayButton`, con variantes primario, secundario y de texto.
  - **Inputs:** `FletwayTextField`, además de numérico y selector.
  - **Cards:** `FletwayCard`.
  - **Estados:** `FletwayLoading`, `FletwayErrorView` y `FletwayEmptyView`.
  - **Diálogos de confirmación:** `FletwayConfirmDialog`.
- Las pantallas y los widgets de feature usan **sólo** estos componentes. Está prohibido usar
  directamente `ElevatedButton`, `TextButton`, `OutlinedButton`, `TextField`, `Card` o
  `AlertDialog` de Material fuera de `lib/shared/widgets/`.
- Ningún componente de UI "suelto": si falta una variante, se agrega al componente compartido
  (parámetro o variante nueva), no se crea uno propio en la feature.
- Los widgets de `presentation/widgets/` de una feature **componen** componentes compartidos (una
  tarjeta de oferta es un `FletwayCard` con contenido); no redefinen estilos.
- Los componentes compartidos consumen sólo tokens y tema, no dependen de Riverpod ni de ninguna
  feature: reciben datos y callbacks por parámetro.
- Estado actual: implementados `FletwayButton`, `FletwayTextField` (con la variante
  `FletwayTextField.decimal` para medidas y montos: coma o punto, unidad como sufijo y
  `FletwayTextField.leerDecimal` para leerlo), `FletwaySelector`, `FletwayCard`, `FletwayLoading`,
  `FletwayErrorView` y `FletwayEmptyView` (importar `widgets.dart`). Se agrega cuando la primera
  pantalla lo necesite: `FletwayConfirmDialog`. Los números se muestran en es-AR con la extensión
  de `lib/shared/extensions/numeros.dart`.

### Decoración mínima de cada pantalla

Hasta la pasada de UI/UX del módulo 15 (`../fletway-backend/docs/PLAN_CONSTRUCCION.md`), toda
pantalla nueva cumple esto, que cuesta poco y evita que la deuda visual crezca:

- **Íconos:** cada ítem de lista lleva un ícono de Material a la izquierda (`leading`), y cada
  encabezado de sección o acceso, su ícono. Nunca emojis.
- **Estados vacíos y de error:** siempre con ícono y, si existe, una acción para salir del
  estado (`FletwayEmptyView(accion: ...)`, `FletwayErrorView(onReintentar: ...)`).
- **Jerarquía:** título del ítem con `titleMedium`, el dato principal destacado (precio, estado,
  fecha) y el detalle secundario con `bodySmall`. Los estados se marcan con color de
  `FletwayEstados` o del `ColorScheme`, además del texto.
- **Objetos del catálogo:** se muestran con `iconoDeObjeto` (catálogo de objetos).

### Documentación dartdoc

- **Obligatorio `///`** en todo elemento público (sin `_`): widgets, clases, constructores con
  parámetros no obvios, funciones, métodos, providers, extensiones y enums.
- Idioma español. La primera oración es un resumen autocontenido; los identificadores se
  referencian con corchetes (`[AuthInterceptor]`).
- Lo mínimo que tiene que explicar cada comentario:
  - **Widgets:** qué muestra, cuándo usarlo, los parámetros que no sean obvios y cuándo se
    dispara cada callback.
  - **Funciones y métodos:** qué hacen, qué devuelven, qué excepciones lanzan (por ejemplo
    `ApiException`) y sus efectos secundarios (red, navegación, escritura en Supabase).
  - **Providers y controllers:** qué estado exponen y de qué otros providers dependen.
  - **Reglas de negocio:** si la UI aplica un RF/RN, citarlo (`RN-05`: top 3).
- Los comentarios `//` internos explican el **por qué**, no el qué.
- El código generado no se documenta a mano.
- **Control:** `public_member_api_docs` no está activa en `analysis_options.yaml`, así que el
  análisis no lo verifica. Se controla en code review: un PR con elementos públicos sin dartdoc
  no se aprueba. Deuda conocida: parte del código actual (por ejemplo la clase `ApiClient`)
  todavía no tiene dartdoc propio.

### Prohibición de emojis

- **Prohibido usar emojis** en la UI (textos visibles, títulos, botones, snackbars,
  notificaciones, placeholders), en código Dart, comentarios, logs, mensajes de commit, nombres
  de branch y archivos de documentación del repo.
- Los íconos de la UI son `Icons` de Material o assets propios, nunca emojis como texto.
- Para estados y marcas en la documentación se usa texto ("Hecho", "Pendiente", "Atención:").
- Los caracteres tipográficos que no son emojis (flechas, `·`, `—`) están permitidos.

---

## 6. Skills disponibles (`.claude/skills/`)

| Skill | Cuándo usarla |
|-------|---------------|
| `new-screen` | Crear una pantalla nueva con el patrón estado/navegación del repo (feature-first, Riverpod `AsyncValue`, ruta `go_router` con guard de rol). |
| `sync-api-models` | Mantener los DTOs/modelos Dart en sincronía con `fletway-backend/docs/ENDPOINTS.md` (fuente de verdad del contrato). Correr cuando el backend avise que cambió el contrato. |
| `feature-scaffold` | Crear la carpeta completa de una feature nueva (`data/ application/ presentation/`) con los archivos base. |

---

## 7. Estado del toolchain

Flutter **3.47.2 / Dart 3.13.2**. Cada integrante usa su instalación: en Windows
`C:\src\flutter` y en Linux `~/development/flutter`; las dos son válidas. **Plataforma objetivo
de esta etapa: sólo Android** (D-17); `ios/` queda generado pero no se mantiene. El proyecto ya
tiene `android/` + `ios/`, `pub get` corrido, `flutter analyze` sin issues y
`build_runner` operativo. Versiones clave: **Riverpod 3**, **go_router 18**,
**freezed 3** (clases `abstract class X with _$X`). El **Android SDK / emulador
NO** está instalado — hace falta solo para `flutter run` en dispositivo, no para
analyze / test / codegen. Detalle y próximos pasos en `docs/ESTADO_PROYECTO.md`.
