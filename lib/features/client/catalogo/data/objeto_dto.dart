import 'package:freezed_annotation/freezed_annotation.dart';

part 'objeto_dto.freezed.dart';
part 'objeto_dto.g.dart';

/// Objeto del catálogo (`GET /catalogo/objetos`, RN-08). Al publicar una
/// solicitud, sus valores se copian a la solicitud (módulo 6).
@freezed
abstract class ObjetoCatalogo with _$ObjetoCatalogo {
  /// Crea el objeto; los campos espejan la API.
  const factory ObjetoCatalogo({
    required String id,
    required String nombre,
    @JsonKey(name: 'peso_estimado_kg') required double pesoEstimadoKg,
    @JsonKey(name: 'largo_m') required double largoM,
    @JsonKey(name: 'ancho_m') required double anchoM,

    /// Eje vertical.
    @JsonKey(name: 'alto_m') required double altoM,

    /// Se puede girar sobre su base.
    @JsonKey(name: 'rotacion_horizontal') required bool rotacionHorizontal,

    /// Se puede acostar.
    @JsonKey(name: 'rotacion_vertical') required bool rotacionVertical,

    /// Admite carga encima.
    required bool apilable,
  }) = _ObjetoCatalogo;

  /// Construye el objeto desde el JSON de la API.
  factory ObjetoCatalogo.fromJson(Map<String, dynamic> json) =>
      _$ObjetoCatalogoFromJson(json);
}
