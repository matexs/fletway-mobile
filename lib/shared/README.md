# lib/shared/

Compartido entre Cliente y Transportista.

- `design_system/` — tokens de diseño (colores, tipografía, espaciados, radios). Ver
                  `CLAUDE.md` §5 "Design system".
- `widgets/`    — único set de componentes de UI reutilizables (botones, inputs, cards,
                  estados de carga/error/vacío, diálogos). Ver `CLAUDE.md` §5
                  "Componentes compartidos".
- `models/`     — DTOs compartidos (Notificacion, Objeto, TipoIncidente, Mensaje…).
                  Generados/actualizados con la skill `sync-api-models`.
- `extensions/` — extensiones sobre tipos base (formato de moneda, fechas intl).
