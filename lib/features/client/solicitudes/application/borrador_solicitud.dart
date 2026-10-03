import 'package:flutter/foundation.dart';

import '../data/objeto_dto.dart';
import '../data/solicitud_dto.dart';

/// Un objeto agregado al formulario de publicación, todavía no enviado: del
/// catálogo ([catalogo]) o cargado a mano (nombre, peso y medidas).
@immutable
class ObjetoBorrador {
  /// Objeto del catálogo.
  const ObjetoBorrador.delCatalogo(ObjetoCatalogo this.catalogo,
      {this.cantidad = 1})
      : nombre = null,
        pesoKg = null,
        largoM = null,
        anchoM = null,
        altoM = null,
        seAcuesta = true,
        apilable = true;

  /// Objeto cargado a mano.
  const ObjetoBorrador.manual({
    required String this.nombre,
    required double this.pesoKg,
    required double this.largoM,
    required double this.anchoM,
    required double this.altoM,
    this.seAcuesta = true,
    this.apilable = true,
    this.cantidad = 1,
  }) : catalogo = null;

  /// Objeto del catálogo, o null si es manual.
  final ObjetoCatalogo? catalogo;

  /// Datos de un objeto manual (null si es del catálogo).
  final String? nombre;
  final double? pesoKg;
  final double? largoM;
  final double? anchoM;
  final double? altoM;

  /// Restricciones de un objeto manual.
  final bool seAcuesta;
  final bool apilable;

  /// Cuántos iguales hay.
  final int cantidad;

  /// Nombre a mostrar.
  String get nombreVisible => catalogo?.nombre ?? nombre!;

  /// Peso por unidad, en kg.
  double get pesoUnitario => catalogo?.pesoEstimadoKg ?? pesoKg!;

  /// Copia con otra [cantidad].
  ObjetoBorrador conCantidad(int cantidad) => catalogo != null
      ? ObjetoBorrador.delCatalogo(catalogo!, cantidad: cantidad)
      : ObjetoBorrador.manual(
          nombre: nombre!,
          pesoKg: pesoKg!,
          largoM: largoM!,
          anchoM: anchoM!,
          altoM: altoM!,
          seAcuesta: seAcuesta,
          apilable: apilable,
          cantidad: cantidad,
        );

  /// Convierte el borrador en el objeto del request: del catálogo sólo manda id
  /// y cantidad (el backend copia el resto, RN-08).
  ObjetoNuevo aRequest() => catalogo != null
      ? ObjetoNuevo(objetoId: catalogo!.id, cantidad: cantidad)
      : ObjetoNuevo(
          nombrePersonalizado: nombre,
          cantidad: cantidad,
          pesoUnitarioKg: pesoKg,
          largoM: largoM,
          anchoM: anchoM,
          altoM: altoM,
          rotacionHorizontal: true,
          rotacionVertical: seAcuesta,
          apilable: apilable,
        );
}

/// Agrega [nuevo] a [objetos]: si el mismo objeto del catálogo ya estaba, suma
/// la cantidad en vez de repetirlo.
List<ObjetoBorrador> agregarObjeto(
  List<ObjetoBorrador> objetos,
  ObjetoBorrador nuevo,
) {
  final id = nuevo.catalogo?.id;
  final i = id == null ? -1 : objetos.indexWhere((o) => o.catalogo?.id == id);
  if (i < 0) return [...objetos, nuevo];
  return [
    for (var j = 0; j < objetos.length; j++)
      j == i
          ? objetos[j].conCantidad(objetos[j].cantidad + nuevo.cantidad)
          : objetos[j],
  ];
}

/// Peso total estimado de [objetos], en kg (sólo informativo para el Cliente).
double pesoTotal(List<ObjetoBorrador> objetos) =>
    objetos.fold(0, (t, o) => t + o.pesoUnitario * o.cantidad);
