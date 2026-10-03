import 'package:flutter/material.dart';

import '../../application/catalogo_provider.dart';

/// Reglas palabra clave → ícono, en orden: la primera que aparece en el nombre
/// gana, así que las más específicas van antes ("mesa de luz" antes que "mesa").
const _reglas = <(String, IconData)>[
  ('aire acondicionado', Icons.ac_unit),
  ('biblioteca', Icons.shelves),
  ('estanteria', Icons.shelves),
  ('bicicleta', Icons.pedal_bike),
  ('valija', Icons.luggage),
  ('bulto', Icons.luggage),
  ('caja', Icons.inventory_2),
  ('cama 1 plaza', Icons.single_bed),
  ('cama', Icons.king_bed),
  ('ropero', Icons.checkroom),
  ('placard', Icons.checkroom),
  ('comoda', Icons.door_sliding),
  ('cajonera', Icons.door_sliding),
  ('escritorio', Icons.desk),
  ('espejo', Icons.filter_frames),
  ('cuadro', Icons.filter_frames),
  ('estufa', Icons.fireplace),
  ('calefactor', Icons.fireplace),
  ('heladera', Icons.kitchen),
  ('horno', Icons.soup_kitchen),
  ('anafe', Icons.soup_kitchen),
  ('lavarropas', Icons.local_laundry_service),
  ('lavavajillas', Icons.countertops),
  ('mesa de luz', Icons.nightlight),
  ('mesa ratona', Icons.table_bar),
  ('mesa', Icons.table_restaurant),
  ('microondas', Icons.microwave),
  ('silla', Icons.chair_alt),
  ('sillon', Icons.chair),
  ('sofa', Icons.weekend),
  ('tv', Icons.tv),
];

/// Ícono de un objeto del catálogo según su nombre (sin mayúsculas ni tildes).
/// Los objetos que no coinciden con ninguna regla, incluidos los que agregue un
/// Administrador, usan un ícono genérico.
IconData iconoDeObjeto(String nombre) {
  final n = normalizarTexto(nombre);
  for (final (clave, icono) in _reglas) {
    if (n.contains(clave)) return icono;
  }
  return Icons.category_outlined;
}
