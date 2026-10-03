import 'package:flutter/material.dart';

/// Colores base de Fletway, por rol semántico (CLAUDE.md §5, "Design system").
///
/// Es el único lugar de la app con literales de color. Los widgets no usan esta
/// clase directamente: leen los colores del tema (`Theme.of(context).colorScheme`
/// y la extensión [FletwayEstados]), que arma `lib/app/theme.dart` a partir de
/// estos valores. Los valores son provisionales y reemplazables (A-2 del plan).
abstract final class FletwayColors {
  /// Color de marca: naranja tostado, amarronado. Es la semilla de la paleta y el
  /// color primario (botones principales, acentos, estados activos).
  static const Color semilla = Color(0xFFC36224);

  /// Gris cálido para el rol secundario: elementos discretos que acompañan al
  /// primario sin competir con él.
  static const Color secundario = Color(0xFF6E6A67);

  /// Gris más claro para el rol terciario (detalles y separadores con acento).
  static const Color terciario = Color(0xFF8C8580);

  /// Fondo y superficies del tema claro.
  static const Color superficieClara = Color(0xFFFFFFFF);

  /// Fondo y superficies del tema oscuro.
  static const Color superficieOscura = Color(0xFF1E1C1B);

  /// Estado de éxito (operación completada, viaje finalizado).
  static const Color exito = Color(0xFF2E7D32);

  /// Estado de advertencia (acciones con consecuencias, por ejemplo un cargo).
  static const Color advertencia = Color(0xFFB26A00);
}

/// Colores de estado que no tienen equivalente en [ColorScheme] (éxito y
/// advertencia). Se registran en el tema y se leen con
/// `Theme.of(context).extension<FletwayEstados>()!`.
@immutable
class FletwayEstados extends ThemeExtension<FletwayEstados> {
  /// Crea la extensión con los colores de estado indicados.
  const FletwayEstados({required this.exito, required this.advertencia});

  /// Valores por defecto, iguales para el tema claro y el oscuro.
  static const FletwayEstados estandar = FletwayEstados(
    exito: FletwayColors.exito,
    advertencia: FletwayColors.advertencia,
  );

  /// Color de éxito.
  final Color exito;

  /// Color de advertencia.
  final Color advertencia;

  @override
  FletwayEstados copyWith({Color? exito, Color? advertencia}) => FletwayEstados(
        exito: exito ?? this.exito,
        advertencia: advertencia ?? this.advertencia,
      );

  @override
  FletwayEstados lerp(ThemeExtension<FletwayEstados>? other, double t) {
    if (other is! FletwayEstados) return this;
    return FletwayEstados(
      exito: Color.lerp(exito, other.exito, t)!,
      advertencia: Color.lerp(advertencia, other.advertencia, t)!,
    );
  }
}
