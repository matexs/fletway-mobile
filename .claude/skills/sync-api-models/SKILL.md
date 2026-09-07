---
name: sync-api-models
description: >-
  Mantener los modelos/DTOs Dart de la app Flutter de Fletway sincronizados con
  el contrato de API del backend, cuya fuente de verdad es
  ../fletway-backend/docs/ENDPOINTS.md (y el esquema en
  ../fletway-backend/docs/DOCUMENTACION_BASE_DE_DATOS.md). Genera/actualiza clases
  freezed + json_serializable que espejan los nombres de campo de la API (español,
  snake_case), actualiza docs/API_CONTRATOS.md y corre build_runner. Usar cuando
  el backend avise que agregó o cambió un endpoint/contrato.
---

# Skill: sync-api-models

## Cuándo usar

- El backend agregó un endpoint o cambió el shape de uno existente (subió la
  "Versión de contrato" en `../fletway-backend/docs/ENDPOINTS.md`).
- Vas a implementar una feature y sus DTOs no existen todavía.
- Revisión periódica de que los modelos no quedaron desalineados.

## Fuentes de verdad (en orden)

1. `../fletway-backend/docs/ENDPOINTS.md` — request/response de cada endpoint.
2. `../fletway-backend/docs/DOCUMENTACION_BASE_DE_DATOS.md` — tipos, nullabilidad,
   tablas de referencia (catálogos `codigo`/`descripcion`).
3. `../fletway-backend/docs/DECISIONES_TECNICAS.md` D-11 — formato de montos,
   fechas, paginación, envelope de error.

> Si el repo backend no está disponible como carpeta hermana, pedir los cambios
> del contrato en texto. No adivinar.

## Reglas de mapeo

| Regla | Detalle |
|-------|---------|
| Nombres | El campo Dart usa el **mismo nombre** que la API (español, snake_case). Si se quiere `camelCase` en Dart, usar `@JsonKey(name: 'snake_case')` — pero por defecto se deja snake_case para evitar una capa de traducción propensa a errores. |
| Tipo | `uuid` → `String`. Timestamp ISO-8601 → `DateTime`. Montos → según D-11 (int centavos o `String` decimal — **no** `double`). |
| Nullabilidad | Espejar exactamente la columna / el campo del response. Un campo opcional del response es `Type?`. |
| Catálogos | Los `*_codigo` de tablas de referencia se modelan como `String` (el `codigo`), no como `enum` Dart, salvo que el set sea chico y cerrado por la ERS (ej. rol, estado de habilitación → enum en `core/auth/app_user.dart`). |
| Snapshots | Los `*_snapshot` de `viaje` son de **solo lectura** en la app: van en el DTO de response de `Viaje`, nunca en un request. |
| Campos calculados | precio, cantidad de viajes, score, `%` comisión, PIN: **solo en responses**. Nunca en un `*Request`. |
| Requests | Clase separada `XxxRequest` con solo lo que el usuario ingresa. |

## Procedimiento

### 1. Diff del contrato

Listar qué endpoints/campos cambiaron desde la última sync (comparar contra
`docs/API_CONTRATOS.md` de este repo, que registra la versión de contrato vista).

### 2. Ubicar cada modelo

- DTO usado por una sola feature → `lib/features/<area>/<feature>/data/<feature>_dto.dart`.
- DTO compartido (`Notificacion`, `Objeto`, `Mensaje`, `TipoIncidente`, …) →
  `lib/shared/models/`.

### 3. Escribir/actualizar las clases

`freezed` + `json_serializable`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<archivo>.freezed.dart';
part '<archivo>.g.dart';

@freezed
class Solicitud with _$Solicitud {
  const factory Solicitud({
    required String id,
    required String origen_direccion,
    required String destino_direccion,
    required bool requiere_escalera,
    int? pisos_escalera,
    required String cotizacion_estimada_monto,   // string decimal (D-11)
    required DateTime creado_en,
  }) = _Solicitud;

  factory Solicitud.fromJson(Map<String, dynamic> json) => _$SolicitudFromJson(json);
}
```

- Para requests: clase propia sin campos calculados, con `toJson()`.
- No borrar campos que el backend todavía envía aunque la UI no los use (rompe
  `fromJson` si son `required`); marcarlos o dejarlos.

### 4. Regenerar

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Actualizar `docs/API_CONTRATOS.md`

- Mover el endpoint de "Planificados" a "Implementados en el backend".
- Anotar la **Versión de contrato del backend** vista.
- Registrar el/los modelo(s) Dart creados y su ubicación.

### 6. Cerrar

- `flutter analyze` limpio.
- Commit: `chore(models): sync con contrato backend vX [RF-YY]`.
- Si algún cambio es incompatible (campo required nuevo, tipo cambiado), avisarlo
  en el resumen y actualizar los repos/controllers que lo usan.

## Checklist

- [ ] Comparé contra `../fletway-backend/docs/ENDPOINTS.md` (no adiviné).
- [ ] Nombres de campo espejan la API (snake_case) o `@JsonKey` explícito.
- [ ] Montos no son `double`; timestamps son `DateTime`.
- [ ] Requests sin campos calculados por el sistema ni snapshots.
- [ ] `build_runner` corrido; `.g.dart`/`.freezed.dart` regenerados.
- [ ] `docs/API_CONTRATOS.md` actualizado con la versión de contrato.
- [ ] `flutter analyze` limpio.
