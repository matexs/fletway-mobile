import 'package:flutter/material.dart';

import '../shared/design_system/design_system.dart';

/// Tema de la app, armado a partir de los tokens de `lib/shared/design_system/`.
///
/// Es el único lugar que traduce tokens a [ThemeData] (CLAUDE.md §5). El color
/// primario es la semilla naranja tostado; secundario y terciario son grises
/// discretos y el fondo del tema claro es blanco.
abstract final class FletwayTheme {
  /// Tema claro.
  static ThemeData get light => _construir(Brightness.light);

  /// Tema oscuro, derivado de la misma semilla.
  static ThemeData get dark => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final esClaro = brillo == Brightness.light;
    final esquema = ColorScheme.fromSeed(
      seedColor: FletwayColors.semilla,
      brightness: brillo,
      // fidelity mantiene el primario fiel al tono de la semilla.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      secondary: FletwayColors.secundario,
      tertiary: FletwayColors.terciario,
      surface: esClaro
          ? FletwayColors.superficieClara
          : FletwayColors.superficieOscura,
    );

    const forma = RoundedRectangleBorder(borderRadius: FletwayRadius.bordeMd);
    const relleno = EdgeInsets.symmetric(
      horizontal: FletwaySpacing.lg,
      vertical: FletwaySpacing.md,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      fontFamily: FletwayTypography.familia,
      scaffoldBackgroundColor: esquema.surface,
      extensions: const [FletwayEstados.estandar],
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: FletwayRadius.bordeMd),
        contentPadding: relleno,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: forma, padding: relleno),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: forma, padding: relleno),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: forma, padding: relleno),
      ),
      cardTheme: const CardThemeData(shape: forma, margin: EdgeInsets.zero),
    );
  }
}
