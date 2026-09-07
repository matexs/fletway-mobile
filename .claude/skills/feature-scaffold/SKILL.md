---
name: feature-scaffold
description: >-
  Crear la estructura completa de una feature nueva en la app Flutter de Fletway:
  carpeta lib/features/<area>/<feature>/ con data/ (repository + dto),
  application/ (controller + providers) y presentation/ (screen + widgets/), más
  el esqueleto de test, siguiendo el patrón feature-first + Riverpod + go_router
  del repo. Usar antes de new-screen cuando la feature todavía no existe.
---

# Skill: feature-scaffold

## Cuándo usar

Cuando vas a empezar una feature que no tiene carpeta todavía (ej. la primera
pantalla de "publicar solicitud", "ofertar", "viaje en curso"). Después se usa
`new-screen` para cada pantalla concreta y `sync-api-models` para los DTOs.

## Decidir `<area>` y `<feature>`

- `<area>` ∈ `auth` (común) | `client` (solo Cliente, RF-05..RF-15) |
  `carrier` (solo Transportista, RF-16..RF-24).
- `<feature>` = sustantivo del dominio, en singular o plural coherente con la
  base: `solicitudes`, `ofertas`, `viaje`, `perfil`, `habilitacion`, `ofertar`,
  `vehiculo`.

Contexto: `CLAUDE.md` §3 y `docs/API_CONTRATOS.md` para saber qué endpoints y
reglas toca la feature.

## Estructura a generar

```
lib/features/<area>/<feature>/
├── data/
│   ├── <feature>_dto.dart          # placeholder: correr sync-api-models (freezed 3: `abstract class`)
│   └── <feature>_repository.dart
├── application/
│   ├── <feature>_providers.dart
│   └── <feature>_controller.dart
└── presentation/
    ├── <feature>_screen.dart       # placeholder: correr new-screen para la pantalla real
    └── widgets/
        └── .gitkeep

test/features/<area>/<feature>/
└── <feature>_controller_test.dart  # esqueleto con mocktail
```

## Plantillas

### `data/<feature>_repository.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final <feature>RepositoryProvider = Provider(
  (ref) => <Feature>Repository(ref.read(apiClientProvider)),
);

class <Feature>Repository {
  <Feature>Repository(this._api);
  final ApiClient _api;

  // TODO(sync-api-models): tipar contra ../fletway-backend/docs/ENDPOINTS.md
  // Future<...> obtener(...) => _api.get('/...');
}
```

### `application/<feature>_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Providers de estado derivado / familias por id. El repo se importa de data/.
```

### `application/<feature>_controller.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final <feature>ControllerProvider =
    AsyncNotifierProvider<<Feature>Controller, <State>>(<Feature>Controller.new);

class <Feature>Controller extends AsyncNotifier<<State>> {
  @override
  Future<<State>> build() async {
    // cargar estado inicial vía ref.read(<feature>RepositoryProvider)
    throw UnimplementedError();
  }

  // Acciones con efecto: llaman al repo, actualizan state, exponen AsyncValue.
}
```

### `presentation/<feature>_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class <Feature>Screen extends ConsumerWidget {
  const <Feature>Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(new-screen): observar el controller, switch sobre AsyncValue.
    return const Scaffold(body: Center(child: Text('<Feature> — TODO')));
  }
}
```

### `test/features/<area>/<feature>/<feature>_controller_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock {}

void main() {
  test('TODO: camino feliz del controller', () {
    expect(true, isTrue);
  });
}
```

## Después de scaffoldear

1. `feature-scaffold` **no** agrega rutas: eso lo hace `new-screen` al crear la
   primera pantalla real (bajo el árbol del rol en `lib/app/router.dart`).
2. Correr `sync-api-models` para completar los DTOs contra el contrato del backend.
3. `flutter analyze` limpio.
4. Commit: `chore(<feature>): scaffold de la feature [RF-XX]`.
5. Anotar la feature en `docs/ESTADO_PROYECTO.md`.

## Checklist

- [ ] `<area>` correcta (Cliente vs Transportista vs común).
- [ ] Las 3 capas creadas (`data` / `application` / `presentation`).
- [ ] Esqueleto de test creado.
- [ ] Sin rutas agregadas todavía (las agrega `new-screen`).
- [ ] `docs/ESTADO_PROYECTO.md` actualizado.
