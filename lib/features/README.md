# lib/features/

Feature-first. Cada feature: `data/` (repos + DTOs) · `application/` (providers
Riverpod) · `presentation/` (screens + widgets). Ver `../../docs/ARQUITECTURA.md`.

- `auth/`    — login + registro (RF-05, RF-16). Común a ambos roles.
- `client/`  — solo Cliente (RF-05..RF-15).
- `carrier/` — solo Transportista (RF-16..RF-24).

Crear una feature nueva con la skill `feature-scaffold`; una pantalla con `new-screen`.
