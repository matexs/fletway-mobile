import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/zonas_controller.dart';
import '../data/zonas_repository.dart';

/// Elección de las zonas de trabajo del Transportista, agrupadas por provincia
/// (RN-04). Sólo ve solicitudes con origen o destino en estas zonas.
class ZonasScreen extends ConsumerStatefulWidget {
  /// Crea la pantalla.
  const ZonasScreen({super.key});

  @override
  ConsumerState<ZonasScreen> createState() => _ZonasScreenState();
}

class _ZonasScreenState extends ConsumerState<ZonasScreen> {
  // Selección en edición; null hasta que llegan las zonas guardadas.
  Set<String>? _elegidas;
  var _guardando = false;

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final falla =
        await ref.read(zonasControllerProvider.notifier).guardar(_elegidas!);
    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(falla?.message ?? 'Zonas guardadas.')),
    );
    if (falla == null && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final zonas = ref.watch(zonasControllerProvider);
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Zonas de trabajo')),
      body: zonas.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: () => ref.invalidate(zonasControllerProvider),
        ),
        data: (z) {
          final elegidas = _elegidas ??= {...z.elegidas};
          final porProvincia = <String, List<Zona>>{};
          for (final zona in z.catalogo) {
            porProvincia.putIfAbsent(zona.provincia, () => []).add(zona);
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: FletwaySpacing.lg,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FletwaySpacing.lg,
                      ),
                      child: Text(
                        'Vas a ver las solicitudes que salen o llegan a estas '
                        'zonas.',
                        style: textos.bodyMedium,
                      ),
                    ),
                    for (final entrada in porProvincia.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          FletwaySpacing.lg,
                          FletwaySpacing.xl,
                          FletwaySpacing.lg,
                          FletwaySpacing.xs,
                        ),
                        child: Text(entrada.key, style: textos.titleSmall),
                      ),
                      for (final zona in entrada.value)
                        CheckboxListTile(
                          title: Text(zona.nombre),
                          value: elegidas.contains(zona.id),
                          onChanged: (marcada) => setState(
                            () => marcada == true
                                ? elegidas.add(zona.id)
                                : elegidas.remove(zona.id),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(FletwaySpacing.lg),
                  child: FletwayButton(
                    texto: elegidas.isEmpty
                        ? 'Guardar sin zonas'
                        : 'Guardar ${elegidas.length} '
                            '${elegidas.length == 1 ? 'zona' : 'zonas'}',
                    onPressed: _guardar,
                    cargando: _guardando,
                    anchoCompleto: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
