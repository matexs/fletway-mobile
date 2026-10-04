import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../ofertas/presentation/widgets/reputacion.dart';
import '../application/perfil_controller.dart';
import '../data/perfil_dto.dart';

/// Perfil público de un Transportista (RF-11): cómo trabaja, su reputación,
/// dónde trabaja, con qué vehículos y qué dicen los Clientes.
class PerfilTransportistaScreen extends ConsumerWidget {
  /// Crea la pantalla del Transportista [transportistaId].
  const PerfilTransportistaScreen({required this.transportistaId, super.key});

  /// Transportista a mostrar.
  final String transportistaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = perfilTransportistaProvider(transportistaId);
    final perfil = ref.watch(provider);
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Transportista')),
      body: perfil.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: () => ref.invalidate(provider),
        ),
        data: (p) => ListView(
          padding: const EdgeInsets.all(FletwaySpacing.lg),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: tema.colorScheme.primaryContainer,
                  foregroundColor: tema.colorScheme.onPrimaryContainer,
                  child: Text(p.nombre.isEmpty ? '?' : p.nombre[0],
                      style: tema.textTheme.titleLarge),
                ),
                const SizedBox(width: FletwaySpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nombre, style: tema.textTheme.titleLarge),
                      Text(
                        'En Fletway desde '
                        '${DateFormat("MMMM 'de' y", 'es_AR').format(p.enFletwayDesde.toLocal())}',
                        style: tema.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: FletwaySpacing.md),
            Reputacion(
              calificacion: p.calificacionPromedio,
              cantidadResenas: p.cantidadResenas,
              tasaCumplimiento: p.tasaCumplimiento,
            ),
            if (p.formaTrabajo != null &&
                p.formaTrabajo!.trim().isNotEmpty) ...[
              const SizedBox(height: FletwaySpacing.xl),
              const FletwaySeccion(
                  icono: Icons.handyman_outlined, titulo: 'Cómo trabaja'),
              const SizedBox(height: FletwaySpacing.sm),
              Text(p.formaTrabajo!, style: tema.textTheme.bodyMedium),
            ],
            const SizedBox(height: FletwaySpacing.xl),
            const FletwaySeccion(
                icono: Icons.map_outlined, titulo: 'Zonas de trabajo'),
            const SizedBox(height: FletwaySpacing.sm),
            _Etiquetas(textos: p.zonas, vacio: 'Sin zonas cargadas.'),
            const SizedBox(height: FletwaySpacing.xl),
            const FletwaySeccion(
                icono: Icons.local_shipping_outlined, titulo: 'Vehículos'),
            const SizedBox(height: FletwaySpacing.sm),
            _Etiquetas(
                textos: p.tiposVehiculo, vacio: 'Sin vehículos activos.'),
            const SizedBox(height: FletwaySpacing.xl),
            const FletwaySeccion(
                icono: Icons.reviews_outlined, titulo: 'Reseñas'),
            if (p.resenas.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: FletwaySpacing.sm),
                child: Text('Todavía no tiene reseñas.',
                    style: tema.textTheme.bodyMedium),
              ),
            for (final r in p.resenas) _ResenaTile(resena: r),
          ],
        ),
      ),
    );
  }
}

class _Etiquetas extends StatelessWidget {
  const _Etiquetas({required this.textos, required this.vacio});

  final List<String> textos;
  final String vacio;

  @override
  Widget build(BuildContext context) => textos.isEmpty
      ? Text(vacio, style: Theme.of(context).textTheme.bodyMedium)
      : Wrap(
          spacing: FletwaySpacing.sm,
          runSpacing: FletwaySpacing.sm,
          children: [for (final t in textos) Chip(label: Text(t))],
        );
}

class _ResenaTile extends StatelessWidget {
  const _ResenaTile({required this.resena});

  final Resena resena;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: tema.colorScheme.primary),
          Text('${resena.calificacion}'),
        ],
      ),
      title: Text(resena.mensaje ?? 'Sin comentario.'),
      subtitle: Text('${resena.clienteNombre} · '
          '${DateFormat('d/M/y', 'es_AR').format(resena.creadoEn.toLocal())}'),
    );
  }
}
