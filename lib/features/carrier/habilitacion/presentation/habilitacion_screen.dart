import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/carga_documento_controller.dart';
import '../application/habilitacion_controller.dart';
import 'widgets/documento_card.dart';
import 'widgets/estado_habilitacion_banner.dart';
import 'widgets/origen_archivo_sheet.dart';

/// Documentación del Transportista: estado de habilitación y carga de los cuatro
/// documentos (RF-16), con el motivo y el reintento si se rechazan (RF-01,
/// D-33). Es el inicio del Transportista mientras no está habilitado.
class HabilitacionScreen extends ConsumerStatefulWidget {
  /// Crea la pantalla.
  const HabilitacionScreen({super.key});

  @override
  ConsumerState<HabilitacionScreen> createState() => _HabilitacionScreenState();
}

class _HabilitacionScreenState extends ConsumerState<HabilitacionScreen> {
  // Tipo que se está subiendo, para mostrar el progreso en su card.
  String? _tipoEnCurso;

  Future<void> _cargar(String tipo) async {
    final origen = await elegirOrigenArchivo(context);
    if (origen == null) return;
    setState(() => _tipoEnCurso = tipo);
    await ref
        .read(cargaDocumentoControllerProvider.notifier)
        .cargar(tipo, origen);
    if (mounted) setState(() => _tipoEnCurso = null);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(cargaDocumentoControllerProvider, (_, siguiente) {
      if (siguiente case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Failure.from(error).message)),
        );
      }
    });
    final habilitacion = ref.watch(habilitacionControllerProvider);
    final cargando = ref.watch(cargaDocumentoControllerProvider).isLoading;
    final controller = ref.read(habilitacionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi documentación'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: ref.read(authControllerProvider.notifier).signOut,
          ),
        ],
      ),
      body: habilitacion.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: controller.recargar,
        ),
        data: (mi) => RefreshIndicator(
          onRefresh: controller.recargar,
          child: ListView(
            padding: const EdgeInsets.all(FletwaySpacing.lg),
            children: [
              EstadoHabilitacionBanner(
                estado: mi.estadoHabilitacion,
                faltanDocumentos: mi.documentos.any((t) => t.ultimo == null),
              ),
              for (final tipo in mi.documentos) ...[
                const SizedBox(height: FletwaySpacing.md),
                DocumentoCard(
                  tipo: tipo,
                  cargando: _tipoEnCurso == tipo.tipoDocumentoCodigo,
                  onCargar:
                      cargando ? null : () => _cargar(tipo.tipoDocumentoCodigo),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
