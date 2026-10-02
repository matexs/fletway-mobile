---
name: new-screen
description: >-
  Crear una pantalla nueva en la app Flutter de Fletway siguiendo el patrón de
  estado y navegación del repo: feature-first (data/application/presentation),
  estado con Riverpod (AsyncValue / Notifier), ruta declarativa en go_router con
  guard por rol Cliente/Transportista, sin lógica de negocio en presentation y
  sin HTTP fuera de data. Usar al implementar la UI de cualquier RF.
---

# Skill: new-screen

## Cuándo usar

Al agregar una pantalla para un RF (o un sub-flujo de un RF). Si la feature no
existe todavía, correr antes `feature-scaffold`.

## Contexto obligatorio antes de escribir código

1. `CLAUDE.md` §3 — qué reglas de negocio debe respetar la UI (top 3, precio no
   editable, flujo de PIN, aviso de cargo al cancelar, chat solo con viaje…).
2. `docs/ARQUITECTURA.md` §2–§4 — capas y guards.
3. `docs/API_CONTRATOS.md` + `../fletway-backend/docs/ENDPOINTS.md` — endpoint(s)
   que alimentan la pantalla. Si el endpoint no existe aún, coordinar con backend;
   no inventar el contrato.

## Ubicación

```
lib/features/<area>/<feature>/presentation/<feature>_screen.dart
lib/features/<area>/<feature>/presentation/widgets/…
```

`<area>` ∈ `auth` | `client` | `carrier`. Cliente y Transportista **no** comparten
pantallas salvo `auth/`; lo común va en `lib/shared/widgets/`.

## Procedimiento

### 1. Ruta en `lib/app/router.dart`

Agregar el `GoRoute` bajo el árbol del rol (`/cliente/...` o `/transportista/...`).
El guard central ya bloquea el árbol ajeno y el no-auth: **no** re-implementar
chequeo de rol dentro de la screen. Rutas de chat/tracking van anidadas bajo
`viajes/:id` (existen solo con viaje confirmado — RI-05).

### 2. Estado en `application/`

- Lectura de datos → `AsyncNotifierProvider` (o `FutureProvider.family` si es
  solo fetch por id) que expone `AsyncValue<T>`.
- Realtime (chat, ubicación) → `StreamProvider.family` sobre el canal de Supabase.
- Acciones con efecto (crear, aceptar, cancelar, cargar PIN) → método en un
  `Notifier`/`AsyncNotifier` que llama al repo y actualiza el estado; exponer un
  `AsyncValue<void>` para el estado del submit.

### 3. Repo en `data/`

- Única capa con red. Usa `ref.read(apiClientProvider)` para el backend, o el
  cliente de `core/supabase` para realtime.
- Devuelve modelos del dominio (DTOs `freezed`), o lanza `ApiException`.
- El cliente **nunca** manda campos calculados por el sistema (precio, viajes,
  score, comisión, PIN, snapshots).

### 4. Screen en `presentation/`

- `ConsumerWidget` / `ConsumerStatefulWidget`. `ref.watch` del provider de estado.
- `switch` sobre `AsyncValue` → `data` / `loading` / `error` (usar los widgets de
  `lib/shared/widgets/`).
- Cero lógica de negocio: formateo con extensiones de `lib/shared/extensions/`;
  decisiones de flujo delegadas al controller.
- Errores: mapear con `Failure.from(e)` y mostrar el mensaje.

### 5. Reglas de UI que la skill debe verificar según el RF

| RF | La pantalla debe… |
|----|-------------------|
| RF-06 | **no** mostrar ningún precio al publicar la solicitud: no hay cotización estimada (RN-01/RNF-04, D-13 del backend). |
| RF-07 | mostrar el `precio_calculado` de cada oferta como texto no editable, sin el desglose de costo (RN-01/RNF-04). |
| RF-07 | listar **3** ofertas ordenadas por score; acción "ver más" para el resto (RN-05). |
| RF-08 | antes de confirmar cancelación, mostrar si habrá **cargo de resarcimiento** (dato del backend) o no (RN-07). |
| RF-12 | habilitar el formulario de reseña **solo** si el viaje está finalizado (PIN de fin validado — RN-06). |
| RF-17 | ocultar/deshabilitar "ofertar" si `user.puedeOfertar == false` (habilitación RF-01). |
| RF-22 | pedir **PIN de inicio** y luego **PIN de fin**, que dicta el Cliente; enviar cada uno con la ubicación GPS (`geolocator`) al backend (RN-06). La pantalla del Transportista **nunca** muestra el valor del PIN (D-26). |
| RF-21 (Cliente) | mostrar el PIN de inicio y el de fin en el viaje del Cliente, para que se los dicte al Transportista (D-26). |
| RF-10/RF-20 | mostrar el chat solo dentro de un `viaje/:id` confirmado (RI-05). |

### 6. Test

- `test/features/<area>/<feature>/` — unit test del controller con `mocktail`
  mockeando el repo (camino feliz + error).
- Golden/widget test si la pantalla tiene reglas visuales fuertes (top 3, PIN).

### 7. Cerrar

- `dart format .` + `flutter analyze` limpio.
- Commit: `feat(<scope>): <pantalla> [RF-XX]` · branch `feat/RF-XX-<slug>`.
- Actualizar `docs/ESTADO_PROYECTO.md`.

## Checklist

- [ ] Ruta agregada bajo el árbol del rol correcto en `router.dart`.
- [ ] Estado vía Riverpod (`AsyncValue`); realtime vía `StreamProvider`.
- [ ] HTTP solo en `data/`; sin lógica de negocio en `presentation/`.
- [ ] El cliente no envía campos calculados por el sistema.
- [ ] Reglas de UI del RF (tabla §5) verificadas.
- [ ] Test del controller.
- [ ] `flutter analyze` limpio + `docs/ESTADO_PROYECTO.md` actualizado.
