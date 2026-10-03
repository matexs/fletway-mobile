import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../data/habilitacion_dto.dart';

/// Un documento requerido con el estado de su última carga y la acción para
/// cargarlo (RF-16). Si fue rechazado muestra el motivo (RF-01).
class DocumentoCard extends StatelessWidget {
  /// Crea la card de [tipo]. [onCargar] se dispara al tocar el botón; mientras
  /// [cargando] es true el botón muestra el progreso.
  const DocumentoCard({
    required this.tipo,
    required this.onCargar,
    this.cargando = false,
    super.key,
  });

  /// Tipo de documento con su última carga.
  final TipoDocumento tipo;

  /// Abre la elección del archivo. Null deshabilita el botón.
  final VoidCallback? onCargar;

  /// true mientras se sube este documento.
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.extension<FletwayEstados>()!;
    final ultimo = tipo.ultimo;
    final (estado, color) = switch (ultimo?.estado) {
      null => ('Sin cargar', tema.colorScheme.onSurfaceVariant),
      'aprobado' => ('Aprobado', colores.exito),
      'rechazado' => ('Rechazado', tema.colorScheme.error),
      _ => ('En revisión', colores.advertencia),
    };
    // Mientras está en revisión no se ofrece cargar otro: el Administrador
    // revisaría el último y el anterior quedaría sin sentido.
    final textoBoton = switch (ultimo?.estado) {
      null => 'Cargar',
      'rechazado' => 'Volver a cargar',
      'aprobado' => 'Reemplazar',
      _ => null,
    };
    return FletwayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tipo.descripcion, style: tema.textTheme.titleMedium),
          const SizedBox(height: FletwaySpacing.xs),
          Text(
            estado,
            style: tema.textTheme.labelLarge?.copyWith(color: color),
          ),
          if (ultimo?.estado == 'rechazado' &&
              ultimo?.motivoRechazo != null) ...[
            const SizedBox(height: FletwaySpacing.sm),
            Text(
              'Motivo: ${ultimo!.motivoRechazo}',
              style: tema.textTheme.bodyMedium,
            ),
          ],
          if (textoBoton != null) ...[
            const SizedBox(height: FletwaySpacing.md),
            FletwayButton(
              texto: textoBoton,
              icono: Icons.upload_file_outlined,
              variante: ultimo == null || ultimo.estado == 'rechazado'
                  ? FletwayButtonVariante.primario
                  : FletwayButtonVariante.secundario,
              cargando: cargando,
              onPressed: onCargar,
            ),
          ],
        ],
      ),
    );
  }
}
