# Mapa de contratos de API — fletway-mobile

> **Fuente de verdad:** `../fletway-backend/docs/ENDPOINTS.md`. Este archivo es solo
> el mapeo *endpoint del backend → feature / repo / modelo Dart* en esta app.
> La skill `sync-api-models` lo mantiene alineado.

**Última actualización:** 2026-10-03 · **Versión de contrato del backend:** `v0` (draft, `ENDPOINTS.md` del 2026-10-03)

---

## Reglas de mapeo

- Un endpoint → un método de repository en `lib/features/<area>/<feature>/data/`.
- El DTO Dart **espeja** el JSON del backend: mismos nombres de campo (español,
  snake_case), vía `@JsonKey` solo si hace falta.
- Errores: el backend responde `{ "error": { "code", "message", "details" } }`.
  `ApiException` (en `core/network`) lo parsea; el `code` (string estable) se usa
  para decidir el mensaje en la UI.
- Auth header: lo agrega `AuthInterceptor` con el JWT de la sesión de Supabase.
  Ningún repo lo maneja a mano.
- Rutas: los paths de abajo son relativos a `API_BASE_URL`, que **ya incluye** el prefijo `/api`
  (el backend publica las rutas de negocio bajo `/api`, D-11).
- Montos: número decimal con 2 posiciones; se muestran con `intl` y locale `es_AR` (M-12).

---

## Implementados en el backend

| Endpoint | App: repo / uso |
|----------|-----------------|
| `GET /healthz`, `GET /readyz` | `core/network` — chequeo de conectividad opcional en el splash. |
| Supabase Auth `signUp` / `signInWithPassword` | `core/auth/auth_repository.dart`. El signUp lleva `rol`, `nombre_completo` y `telefono` en la metadata (D-18); el trigger de la base crea `usuario`. |
| `GET /me` | `core/auth/perfil_repository.dart` → `Me` (`shared/models/me.dart`). Única fuente del rol y la habilitación (`AuthController`). |
| `POST /auth/registro/cliente`, `POST /auth/registro/transportista` | `PerfilRepository.completarRegistro`, sin body; responde `Me`. Lo llama el `AuthController` cuando `registro_completo` es false (idempotente). |
| Supabase Storage, bucket `documentos-transportista` | `features/carrier/habilitacion/data/habilitacion_repository.dart`: sube el archivo a `transportista/{usuario_id}/{tipo}-{milisegundos}.{ext}` (jpg, png o pdf de hasta 10 MB, validado antes de subir, D-19). |
| `POST /transportista/documentos`, `GET /transportista/documentos` | Mismo repositorio → `Documento`, `TipoDocumento`, `MiHabilitacion` (`data/habilitacion_dto.dart`). El estado de habilitación también actualiza el `AuthController`. |
| `GET /tipos-vehiculo`, `POST/GET /transportista/vehiculos`, `PUT .../{id}/activo`, `PUT/GET .../{id}/costos` | `features/carrier/vehiculo/data/vehiculo_repository.dart` → `TipoVehiculo`, `Vehiculo`, `NuevoVehiculo`, `CostosVehiculo` (`vehiculo_dto.dart`). Medidas y montos como `double` (números JSON, D-11). `costos_no_cargados` se traduce a null. |
| `GET /zonas`, `GET/PUT /transportista/zonas` | `features/carrier/zonas/data/zonas_repository.dart` → `Zona`, set de ids. |
| `PUT /transportista/disponibilidad` | `features/carrier/inicio/data/disponibilidad_repository.dart` → `Me`, que se aplica a la sesión (`AuthController.aplicarPerfil`). `Me.disponible` viene también en `GET /me`. |
| `GET /catalogo/objetos` | `features/client/catalogo/data/catalogo_repository.dart` → `ObjetoCatalogo` (`objeto_dto.dart`); `catalogoProvider` lo pide una vez por sesión. |

---

## Planificados (seguir el orden de `PLAN_CONSTRUCCION.md`)

| Mód. | RF/RN | Endpoint (relativo a `API_BASE_URL`) | Rol | Feature en esta app | Modelo(s) Dart |
|------|-------|--------------------------------------|-----|---------------------|----------------|
| 6 | RF-06 | `POST /solicitudes`, `GET /solicitudes`, `GET /solicitudes/{id}` | Cliente | `features/client/solicitudes` | `Solicitud`, `SolicitudObjeto` (sin monto, D-13) |
| 6 | RF-06 | `POST /solicitudes/{id}/cancelar`, `POST /solicitudes/{id}/republicar` | Cliente | `features/client/solicitudes` | `RepublicarRequest` |
| 7 | RF-17 / RN-04 | `GET /transportista/solicitudes` | Transportista | `features/carrier/ofertar` | `SolicitudCompatible` |
| 8 | RF-17 / RN-01 / RN-02 | `POST /solicitudes/{id}/ofertas` | Transportista | `features/carrier/ofertar` | `OfertaRequest` (`vehiculo_id`, `cantidad_ayudantes` 0..3), `Oferta` |
| 8 | RF-17 | `POST /ofertas/{id}/retirar`, `GET /transportista/ofertas` | Transportista | `features/carrier/ofertar` | `Oferta` |
| 9 | RF-07 / RN-05 | `GET /solicitudes/{id}/ofertas` (top 3, `?ver_mas=true`) | Cliente | `features/client/ofertas` | `OfertaConScore` (sólo `precio_calculado`, sin desglose) |
| 9 | RF-11 | `GET /transportistas/{id}` | Cliente | `features/client/perfil` | `PerfilTransportista`, `Resena` |
| 9 | RF-07 | `POST /ofertas/{id}/aceptar` | Cliente | `features/client/ofertas` | `Viaje` |
| 10 | RF-21 | `GET /viajes/{id}` | ambos (del viaje) | `features/*/viaje` | `Viaje` (con PIN **sólo** para el Cliente, D-26) |
| 10 | RN-07 | `POST /viajes/{id}/salida` | Transportista | `features/carrier/viaje` | — |
| 10 | RF-22 / RN-06 | `POST /viajes/{id}/pin-inicio`, `POST /viajes/{id}/pin-fin` | Transportista | `features/carrier/viaje` | `PinRequest` (pin + lat/lng + precisión) |
| 10 | RF-10 / RF-20 | Supabase Realtime, tabla `mensaje` | ambos (del viaje) | `features/*/viaje` (chat) | `Mensaje` |
| 10 | RF-15 / RI-04 | Supabase Realtime, tabla `viaje_ubicacion` | Cliente lee / Transportista inserta | `features/*/viaje` (tracking) | `ViajeUbicacion` |
| 11 | RF-08 / RF-19 / RN-07 | `POST /viajes/{id}/cancelar` | ambos | `features/*/viaje` | `CancelacionResultado` (incluye el cargo, si hubo) |
| 12 | RI-03 | `POST /transportista/cuenta-pago` | Transportista | `features/carrier/pagos` | `CuentaPago` |
| 13 | RF-12 / RN-06 | `POST /viajes/{id}/resena` | Cliente | `features/client/viaje` | `ResenaRequest` |
| 13 | RF-13 / RF-23 | `POST /incidentes` | ambos | `shared` | `IncidenteRequest`, `TipoIncidente` |
| 13 | RF-09 | `GET /notificaciones`, `POST /notificaciones/{id}/leida` | ambos | `shared` | `Notificacion`, `TipoNotificacion` |
| 14 | RF-14 / RF-24 | `GET /viajes?rol=...` | ambos | `features/*/viaje` | `ViajeResumen` |
