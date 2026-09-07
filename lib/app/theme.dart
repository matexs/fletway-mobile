import 'package:flutter/material.dart';

/// Tema base de la app. Placeholder: ajustar colores/tipografía cuando exista
/// diseño. El diseño detallado de UI está fuera del alcance de la ERS (§1.2).
class FletwayTheme {
  const FletwayTheme._();

  static const _seed = Color(0xFF1B6EF3);

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      );

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      );
}
