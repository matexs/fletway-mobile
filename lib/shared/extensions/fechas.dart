import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Fechas como las intercambia la API (`AAAA-MM-DD`) y como las lee el usuario
/// (es-AR). Requiere `initializeDateFormatting('es_AR')` (lo hace `main`).
extension FormatoFecha on DateTime {
  /// `2026-10-12`, para mandar a la API.
  String get paraApi => DateFormat('yyyy-MM-dd').format(this);

  /// `lunes 12 de octubre`.
  String get larga => DateFormat("EEEE d 'de' MMMM", 'es_AR').format(this);

  /// `lun 12/10`.
  String get corta => DateFormat('EEE d/M', 'es_AR').format(this);
}

/// Hora como la intercambia la API (`HH:MM`).
extension FormatoHora on TimeOfDay {
  /// `09:00`.
  String get paraApi =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Convierte `AAAA-MM-DD` de la API en fecha (sin hora). Lanza
/// [FormatException] si el texto no es una fecha.
DateTime fechaDesdeApi(String texto) =>
    DateFormat('yyyy-MM-dd').parseStrict(texto);
