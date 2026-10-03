import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/fechas.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/solicitudes_controller.dart';
import '../data/solicitud_dto.dart';
import 'widgets/estado_solicitud.dart';
import 'widgets/icono_objeto.dart';

/// Detalle de una solicitud del Cliente, con las acciones según su estado:
/// cancelar si está publicada y republicar si venció (D-20). Las ofertas se
/// suman en el módulo 9.
class DetalleSolicitudScreen extends ConsumerWidget {
  /// Crea la pantalla de la solicitud [solicitudId].
  const DetalleSolicitudScreen({required this.solicitudId, super.key});

  /// Solicitud a mostrar.
  final String solicitudId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = detalleSolicitudProvider(solicitudId);
    final solicitud = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    void avisar(String texto) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));

    Future<void> cancelar() async {
      final ok = await confirmarFletway(
        context,
        titulo: '¿Cancelar la solicitud?',
        mensaje: 'No tiene costo. Las ofertas que recibiste se descartan. Si '
            'querés cambiar algo, después podés publicar otra.',
        textoConfirmar: 'Cancelar solicitud',
        icono: Icons.cancel_outlined,
      );
      if (!ok) return;
      final falla = await controller.cancelar();
      avisar(falla?.message ?? 'Solicitud cancelada.');
    }

    Future<void> republicar() async {
      final hoy = DateUtils.dateOnly(DateTime.now());
      final fecha = await showDatePicker(
        context: context,
        helpText: 'Nueva fecha del traslado',
        initialDate: hoy,
        firstDate: hoy,
        lastDate: hoy.add(const Duration(days: 365)),
      );
      if (fecha == null) return;
      final (nueva, falla) = await controller.republicar(fecha.paraApi);
      if (falla != null) {
        avisar(falla.message);
        return;
      }
      avisar('Publicamos la solicitud de nuevo.');
      if (context.mounted) {
        context.pushReplacement('/cliente/solicitudes/${nueva!.id}');
      }
    }

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
            EstadoSolicitudChip(estado: s.estado),
            const SizedBox(height: FletwaySpacing.md),
            _Resumen(solicitud: s),
            const SizedBox(height: FletwaySpacing.xl),
            FletwaySeccion(
              icono: Icons.inventory_2_outlined,
              titulo: 'Qué llevás',
              detalle: s.cantidadAyudantesSolicitados == 0
                  ? 'Sin ayudantes pedidos.'
                  : 'Pediste ${s.cantidadAyudantesSolicitados} '
                      '${s.cantidadAyudantesSolicitados == 1 ? 'ayudante' : 'ayudantes'}.',
            ),
            for (final o in s.objetos) _ObjetoTile(objeto: o),
            const SizedBox(height: FletwaySpacing.xl),
            if (s.estado == 'publicada')
              FletwayButton(
                texto: 'Cancelar solicitud',
                icono: Icons.cancel_outlined,
                variante: FletwayButtonVariante.secundario,
                anchoCompleto: true,
                onPressed: cancelar,
              ),
            if (s.estado == 'vencida') ...[
              Text(
                'La fecha ya pasó sin un viaje confirmado. Podés publicarla de '
                'nuevo con otra fecha.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: FletwaySpacing.md),
              FletwayButton(
                texto: 'Republicar con otra fecha',
                icono: Icons.event_repeat_outlined,
                anchoCompleto: true,
                onPressed: republicar,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.solicitud});

  final Solicitud solicitud;

  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final franja = s.franjaHorariaInicio == null
        ? 'Lo antes posible'
        : 'De ${s.franjaHorariaInicio} a ${s.franjaHorariaFin}';
    return FletwayCard(
      child: Column(
        children: [
          _Linea(
            icono: Icons.event_outlined,
            titulo: fechaDesdeApi(s.fechaServicioDeseada).larga,
            detalle: franja,
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
        ' · ${o.pesoUnitarioKg.legible} kg c/u',
      ),
    );
  }
}
