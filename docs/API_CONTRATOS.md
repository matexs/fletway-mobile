# Mapa de contratos de API — fletway-mobile

> **Fuente de verdad:** `../fletway-backend/docs/ENDPOINTS.md`. Este archivo es solo
> el mapeo *endpoint del backend → feature / repo / modelo Dart* en esta app.
> La skill `sync-api-models` lo mantiene alineado.

**Última actualización:** 2026-10-01 · **Versión de contrato del backend:** `v0` (draft, `ENDPOINTS.md` del 2026-10-01)

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

*(nada de negocio todavía)*

---

## Planificados (seguir el orden de `PLAN_CONSTRUCCION.md`)

| Mód. | RF/RN | Endpoint (relativo a `API_BASE_URL`) | Rol | Feature en esta app | Modelo(s) Dart |
|------|-------|--------------------------------------|-----|---------------------|----------------|
| 2 | (login) | Supabase Auth (GoTrue) directo | ambos | `core/auth` | `AppUser` |
| 2 | — | `GET /me` | ambos | `core/auth` | `Perfil` (rol, habilitación) |
| 2 | RF-05 | `POST /auth/registro/cliente` | Cliente | `features/auth` | `RegistroClienteRequest` |
| 2 | RF-16 | `POST /auth/registro/transportista` | Transportista | `features/auth` | `RegistroTransportistaRequest` |
| 3 | RF-16 | `POST /transportista/documentos`, `GET /transportista/documentos` | Transportista | `features/carrier/habilitacion` | `DocumentoTransportista` |
| 4 | RF-18 | `POST /transportista/vehiculos`, `GET /transportista/vehiculos`, `PUT /transportista/vehiculos/{id}/costos` | Transportista | `features/carrier/vehiculo` | `Vehiculo`, `VehiculoCosto`, `TipoVehiculo` |
| 4 | RN-04 | `GET /zonas`, `PUT /transportista/zonas`, `PUT /transportista/disponibilidad` | Transportista | `features/carrier/vehiculo` (o `zonas`) | `Zona` |
| 5 | RN-08 | `GET /catalogo/objetos` | ambos | `shared` | `Objeto` |
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
