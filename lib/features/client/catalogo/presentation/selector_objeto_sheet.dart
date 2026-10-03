import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/catalogo_provider.dart';
import '../data/objeto_dto.dart';
import 'widgets/objeto_tile.dart';

/// Abre el catálogo de objetos (RN-08) en un panel inferior con buscador y
/// devuelve el objeto elegido, o null si se cierra. Lo usa la publicación de la
/// solicitud (RF-06).
Future<ObjetoCatalogo?> elegirObjetoDelCatalogo(BuildContext context) =>
    showModalBottomSheet<ObjetoCatalogo>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: SelectorObjeto(),
      ),
    );

/// Buscador y lista del catálogo; al tocar un objeto cierra el panel con él.
class SelectorObjeto extends ConsumerStatefulWidget {
  /// Crea el selector.
  const SelectorObjeto({super.key});

  @override
  ConsumerState<SelectorObjeto> createState() => _SelectorObjetoState();
}

class _SelectorObjetoState extends ConsumerState<SelectorObjeto> {
  var _texto = '';

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(catalogoProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FletwaySpacing.lg),
          child: FletwayTextField(
            etiqueta: 'Buscar objeto',
            onChanged: (t) => setState(() => _texto = t),
          ),
        ),
        const SizedBox(height: FletwaySpacing.sm),
        Expanded(
          child: catalogo.when(
            loading: () => const FletwayLoading(),
            error: (e, _) => FletwayErrorView(
              mensaje: Failure.from(e).message,
              onReintentar: () => ref.invalidate(catalogoProvider),
            ),
            data: (objetos) {
              final filtrados = filtrarObjetos(objetos, _texto);
              if (filtrados.isEmpty) {
                return const FletwayEmptyView(
                  mensaje:
                      'No está en el catálogo. Podés cargarlo a mano con sus '
                      'medidas al publicar la solicitud.',
                  icono: Icons.search_off,
                );
              }
              return ListView.builder(
                itemCount: filtrados.length,
                itemBuilder: (context, i) => ObjetoTile(
                  objeto: filtrados[i],
                  onTap: () => Navigator.of(context).pop(filtrados[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
