import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/icono_objeto.dart';
import '../data/catalogo_repository.dart';
import '../data/objeto_dto.dart';

/// Catálogo de objetos. Se pide una vez por sesión: lo cambia sólo un
/// Administrador y rara vez. Depende de [catalogoRepositoryProvider].
final catalogoProvider = FutureProvider<List<ObjetoCatalogo>>(
  (ref) => ref.watch(catalogoRepositoryProvider).objetos(),
);

/// Filtra [objetos] por [texto] en el nombre, sin distinguir mayúsculas ni
/// tildes ("sofa" encuentra "Sofá 2 cuerpos"). Con texto vacío devuelve todos.
List<ObjetoCatalogo> filtrarObjetos(
  List<ObjetoCatalogo> objetos,
  String texto,
) {
  final buscado = normalizarTexto(texto.trim());
  if (buscado.isEmpty) return objetos;
  return [
    for (final o in objetos)
      if (normalizarTexto(o.nombre).contains(buscado)) o,
  ];
}
