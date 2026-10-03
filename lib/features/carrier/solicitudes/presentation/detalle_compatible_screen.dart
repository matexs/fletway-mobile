import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/fechas.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/models/solicitud.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/solicitudes_compatibles_controller.dart';

/// Detalle de una solicitud compatible para el Transportista: cuándo, desde
/// dónde, hasta dónde, el acceso y qué hay que llevar. Desde acá se va a
/// ofertar (módulo 8).
class DetalleCompatibleScreen extends ConsumerWidget {
  /// Crea la pantalla de la solicitud [solicitudId].
  const DetalleCompatibleScreen({required this.solicitudId, super.key});

  /// Solicitud a mostrar.
  final String solicitudId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = detalleCompatibleProvider(solicitudId);
    final solicitud = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitud')),
      body: solicitud.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: () => ref.invalidate(provider),
        ),
        data: (s) => ListView(
          padding: const EdgeInsets.all(FletwaySpacing.lg),
          children: [
            FletwayCard(
              child: Column(
                children: [
                  _Linea(
                    icono: Icons.event_outlined,
                    titulo: fechaDesdeApi(s.fechaServicioDeseada).larga,
                    detalle: s.franjaHorariaInicio == null
                        ? 'Lo antes posible'
                        : 'De ${s.franjaHorariaInicio} a ${s.franjaHorariaFin}',
                  ),
                  _Linea(
                    icono: Icons.trip_origin,
                    titulo: s.origen.direccion,
                    detalle: _acceso(s.origen),
                  ),
                  _Linea(
                    icono: Icons.place_outlined,
                    titulo: s.destino.direccion,
                    detalle: _acceso(s.destino),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FletwaySpacing.xl),
            FletwaySeccion(
              icono: Icons.inventory_2_outlined,
              titulo: 'Qué hay que llevar',
              detalle: s.cantidadAyudantesSolicitados == 0
                  ? 'No pide ayudantes.'
                  : 'Pide ${s.cantidadAyudantesSolicitados} '
                      '${s.cantidadAyudantesSolicitados == 1 ? 'ayudante' : 'ayudantes'} '
                      '(orientativo).',
            ),
            for (final o in s.objetos) _ObjetoTile(objeto: o),
          ],
        ),
      ),
    );
  }

  static String _acceso(PuntoSolicitud p) {
    final pisos = p.pisos == 0
        ? 'planta baja'
        : '${p.pisos} ${p.pisos == 1 ? 'piso' : 'pisos'} por escalera';
    return '${p.zonaNombre} · $pisos'
        '${p.ascensorUtilizable ? ' · con ascensor' : ''}'
        '${p.distanciaVehiculoM > 0 ? ' · ${p.distanciaVehiculoM.legible} m a pie' : ''}';
  }
}

class _Linea extends StatelessWidget {
  const _Linea(
      {required this.icono, required this.titulo, required this.detalle});

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icono, color: Theme.of(context).colorScheme.primary),
        title: Text(titulo),
        subtitle: Text(detalle),
      );
}

class _ObjetoTile extends StatelessWidget {
  const _ObjetoTile({required this.objeto});

  final ObjetoSolicitud objeto;

  @override
  Widget build(BuildContext context) {
    final o = objeto;
    final colores = Theme.of(context).colorScheme;
    final restricciones = [
      if (!o.rotacionVertical) 'no se acuesta',
      if (!o.apilable) 'sin carga encima',
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colores.primaryContainer,
        foregroundColor: colores.onPrimaryContainer,
        child: Icon(
            o.objetoId != null ? iconoDeObjeto(o.nombre) : Icons.edit_note),
      ),
      title: Text('${o.cantidad} × ${o.nombre}'),
      subtitle: Text(
        '${o.largoM.paraCampo} × ${o.anchoM.paraCampo} × ${o.altoM.paraCampo} m'
        ' · ${o.pesoUnitarioKg.legible} kg c/u'
        '${restricciones.isEmpty ? '' : '\n${restricciones.join(' · ')}'}',
      ),
      isThreeLine: restricciones.isNotEmpty,
    );
  }
}
