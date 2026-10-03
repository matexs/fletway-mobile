import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/shared/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FletwayTheme', () {
    test('el tema claro usa fondo blanco y secundarios grises', () {
      final tema = FletwayTheme.light;
      expect(tema.colorScheme.brightness, Brightness.light);
      expect(tema.colorScheme.surface, FletwayColors.superficieClara);
      expect(tema.colorScheme.secondary, FletwayColors.secundario);
      expect(tema.colorScheme.tertiary, FletwayColors.terciario);
    });

    test('el tema oscuro usa la superficie oscura', () {
      final tema = FletwayTheme.dark;
      expect(tema.colorScheme.brightness, Brightness.dark);
      expect(tema.colorScheme.surface, FletwayColors.superficieOscura);
    });

    test('registra los colores de estado como extensión', () {
      for (final tema in [FletwayTheme.light, FletwayTheme.dark]) {
        final estados = tema.extension<FletwayEstados>();
        expect(estados, isNotNull);
        expect(estados!.exito, FletwayColors.exito);
        expect(estados.advertencia, FletwayColors.advertencia);
      }
    });

    test('el primario conserva el tono naranja de la semilla', () {
      final primario = HSLColor.fromColor(
        FletwayTheme.light.colorScheme.primary,
      );
      final semilla = HSLColor.fromColor(FletwayColors.semilla);
      expect((primario.hue - semilla.hue).abs(), lessThan(15));
    });
  });
}
