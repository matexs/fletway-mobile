# Mapa de contratos de API — fletway-mobile

> **Fuente de verdad:** `../fletway-backend/docs/ENDPOINTS.md`. Este archivo es solo
> el mapeo *endpoint del backend → feature / repo / modelo Dart* en esta app.
> La skill `sync-api-models` lo mantiene alineado.

**Última actualización:** 2026-09-26 · **Versión de contrato del backend:** `v0` (draft, `ENDPOINTS.md` del 2026-09-24)

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

---

## Implementados en el backend

| Endpoint | App: repo / uso |
|----------|-----------------|
| `GET /healthz`, `GET /readyz` | `core/network` — chequeo de conectividad opcional en el splash. |

*(nada de negocio todavía)*

---

## Planificados (seguir el orden que fije el backend)

| RF/RN | Endpoint (propuesto, ver backend) | Rol | Feature en esta app | Modelo(s) Dart |
|-------|-----------------------------------|-----|---------------------|----------------|
| RF-05 | `POST /auth/registro/cliente` | Cliente | `features/auth` | `RegistroClienteRequest` |
| RF-16 | `POST /auth/registro/transportista` | Transportista | `features/auth` | `RegistroTransportistaRequest`, `DocumentoUpload` |
| (login) | Supabase Auth (GoTrue) directo | ambos | `core/auth` | `AppUser` |
| RF-18 | `POST /transportista/vehiculos` | Transportista | `features/carrier/vehiculo` | `Vehiculo`, `TipoVehiculo` |
| RF-06 | `POST /solicitudes` | Cliente | `features/client/solicitudes` | `Solicitud`, `SolicitudObjeto` (sin monto: no hay cotización estimada, D-13 del backend) |
| RF-06 / RN-08 | `GET /catalogo/objetos` | ambos | `shared` o `features/client/solicitudes` | `Objeto` |
| RF-17 / RN-04 | `GET /transportista/solicitudes` | Transportista | `features/carrier/ofertar` | `SolicitudCompatible` |
| RF-17 / RN-01 / RN-02 | `POST /solicitudes/{id}/ofertas` | Transportista | `features/carrier/ofertar` | `OfertaRequest` (`vehiculo_id`, `cantidad_ayudantes`), `Oferta` (precio y viajes calculados por el backend; error de validación si la carga no entra en el vehículo) |
| RF-07 / RN-05 | `GET /solicitudes/{id}/ofertas` (top 3) | Cliente | `features/client/ofertas` | `OfertaConScore` (sólo `precio_calculado`, sin desglose de costo) |
| RF-07 | `POST /ofertas/{id}/aceptar` | Cliente | `features/client/ofertas` | `Viaje` |
| RF-08 / RN-07 | `POST /viajes/{id}/cancelar` | Cliente | `features/client/viaje` | `CancelacionResultado` (incluye si hubo cargo) |
| RF-19 | `POST /viajes/{id}/cancelar` | Transportista | `features/carrier/viaje` | `CancelacionResultado` |
| RF-21 | `GET /viajes/{id}` | ambos (del viaje) | `features/*/viaje` | `Viaje` (incluye PIN para el Transportista) |
| RF-22 / RN-06 | `POST /viajes/{id}/pin-inicio`, `.../pin-fin` | Transportista | `features/carrier/viaje` | `PinRequest` (pin + lat/lng) |
| RF-12 / RN-06 | `POST /viajes/{id}/resena` | Cliente | `features/client/viaje` | `ResenaRequest` |
| RF-11 | `GET /transportistas/{id}` | Cliente | `features/client/perfil` | `PerfilTransportista`, `Resena` |
| RF-13 / RF-23 | `POST /incidentes` | ambos | `shared` | `IncidenteRequest`, `TipoIncidente` |
| RF-14 / RF-24 | `GET /viajes?rol=...` | ambos | `features/*/viaje` | `ViajeResumen` |
| RF-09 | `GET /notificaciones`, `POST /notificaciones/{id}/leida` | ambos | `shared` | `Notificacion`, `TipoNotificacion` |
| RF-10 / RF-20 | Supabase Realtime — tabla `mensaje` | ambos (del viaje) | `features/*/viaje` (chat) | `Mensaje` |
| RF-15 / RI-04 | Supabase Realtime — tabla `viaje_ubicacion` | Cliente lee / Transportista inserta | `features/*/viaje` (tracking) | `ViajeUbicacion` |
