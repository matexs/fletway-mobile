/// Tipografía de Fletway (CLAUDE.md §5, "Design system").
///
/// Se usa la escala por defecto de Material 3 (`displayLarge` a `labelSmall`) y
/// la fuente del sistema, sin fuente propia. Los widgets leen los estilos de
/// `Theme.of(context).textTheme`; nunca crean un `TextStyle` con tamaños
/// escritos a mano.
abstract final class FletwayTypography {
  /// Familia tipográfica. `null` usa la fuente por defecto de la plataforma.
  static const String? familia = null;
}
