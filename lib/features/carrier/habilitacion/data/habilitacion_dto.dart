import 'package:freezed_annotation/freezed_annotation.dart';

part 'habilitacion_dto.freezed.dart';
part 'habilitacion_dto.g.dart';

/// Documento cargado por el Transportista (`Documento` en
/// `../fletway-backend/docs/ENDPOINTS.md`).
@freezed
abstract class Documento with _$Documento {
  /// Crea el documento; los campos espejan la API.
  const factory Documento({
    required String id,
    @JsonKey(name: 'tipo_documento_codigo') required String tipoDocumentoCodigo,

    /// `pendiente`, `aprobado` o `rechazado`.
    required String estado,
    @JsonKey(name: 'motivo_rechazo') String? motivoRechazo,
    @JsonKey(name: 'cargado_en') required DateTime cargadoEn,
    @JsonKey(name: 'revisado_en') DateTime? revisadoEn,
  }) = _Documento;

  /// Construye el documento desde el JSON de la API.
  factory Documento.fromJson(Map<String, dynamic> json) =>
      _$DocumentoFromJson(json);
}

/// Un tipo de documento requerido con el último documento cargado de ese tipo.
@freezed
abstract class TipoDocumento with _$TipoDocumento {
  /// Crea el tipo; [ultimo] es null si todavía no cargó ninguno.
  const factory TipoDocumento({
    @JsonKey(name: 'tipo_documento_codigo') required String tipoDocumentoCodigo,
    required String descripcion,
    Documento? ultimo,
  }) = _TipoDocumento;

  /// Construye el tipo desde el JSON de la API.
  factory TipoDocumento.fromJson(Map<String, dynamic> json) =>
      _$TipoDocumentoFromJson(json);
}

/// Estado de habilitación y documentos del Transportista
/// (`GET /transportista/documentos`).
@freezed
abstract class MiHabilitacion with _$MiHabilitacion {
  /// Crea el estado; los campos espejan la API.
  const factory MiHabilitacion({
    /// `pendiente`, `habilitado` o `rechazado` (D-33).
    @JsonKey(name: 'estado_habilitacion') required String estadoHabilitacion,
    required List<TipoDocumento> documentos,
  }) = _MiHabilitacion;

  /// Construye el estado desde el JSON de la API.
  factory MiHabilitacion.fromJson(Map<String, dynamic> json) =>
      _$MiHabilitacionFromJson(json);
}
