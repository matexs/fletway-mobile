import 'package:flutter/foundation.dart';

/// Zona del catálogo (`GET /zonas`).
@immutable
class Zona {
  /// Crea la zona.
  const Zona({required this.id, required this.nombre, required this.provincia});

  /// Construye la zona desde el JSON de la API.
  factory Zona.fromJson(Map<String, dynamic> json) => Zona(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        provincia: json['provincia'] as String,
      );

  /// Id de la zona.
  final String id;

  /// Partido o localidad.
  final String nombre;

  /// Provincia (o CABA).
  final String provincia;
}
