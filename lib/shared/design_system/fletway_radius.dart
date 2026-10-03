import 'package:flutter/widgets.dart';

/// Radios de borde de Fletway (CLAUDE.md §5, "Design system").
abstract final class FletwayRadius {
  /// 4 px.
  static const double sm = 4;

  /// 8 px. Radio habitual de botones, campos y cards.
  static const double md = 8;

  /// 16 px.
  static const double lg = 16;

  /// Píldora: bordes completamente redondeados.
  static const double full = 999;

  /// [BorderRadius] de [sm] en todas las esquinas.
  static const BorderRadius bordeSm = BorderRadius.all(Radius.circular(sm));

  /// [BorderRadius] de [md] en todas las esquinas.
  static const BorderRadius bordeMd = BorderRadius.all(Radius.circular(md));

  /// [BorderRadius] de [lg] en todas las esquinas.
  static const BorderRadius bordeLg = BorderRadius.all(Radius.circular(lg));
}
