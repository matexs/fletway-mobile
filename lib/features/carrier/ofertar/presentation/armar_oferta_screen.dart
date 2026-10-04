import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../solicitudes/application/solicitudes_compatibles_controller.dart';
import '../../vehiculo/application/vehiculos_controller.dart';
import '../../vehiculo/data/vehiculo_dto.dart';
import '../application/armar_oferta_controller.dart';
import '../data/oferta_dto.dart';
import 'widgets/desglose_oferta_view.dart';

/// Armado de la oferta (RF-17): el Transportista elige vehículo y ayudantes y
/// ve el precio y los viajes que calcula el sistema (RN-01, RN-02), o el motivo
/// por el que la carga no entra, antes de enviarla.
class ArmarOfertaScreen extends ConsumerWidget {
  /// Crea la pantalla para la solicitud [solicitudId].
  const ArmarOfertaScreen({required this.solicitudId, super.key});

  /// Solicitud a la que se oferta.
  final String solicitudId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = armarOfertaProvider(solicitudId);
    final estado = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final vehiculos = ref.watch(vehiculosControllerProvider);
    final pedidos = ref
        .watch(detalleCompatibleProvider(solicitudId))
        .value
        ?.cantidadAyudantesSolicitados;

    Future<void> enviar() async {
      final precio = estado.cotizacion?.value?.precioCalculado;
      if (precio == null) return;
      final confirmado = await confirmarFletway(
        context,
        titulo: 'Enviar la oferta',
        mensaje: 'El Cliente va a ver ${precio.pesos}. La oferta no se edita: '
            'si querés cambiarla, la retirás y ofertás de nuevo.',
        textoConfirmar: 'Enviar',
        icono: Icons.send_outlined,
      );
      if (!confirmado || !context.mounted) return;
      final error = await controller.ofertar();
      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Oferta enviada.')));
      context.pushReplacement('/transportista/ofertas');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ofertar')),
      body: vehiculos.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: () => ref.invalidate(vehiculosControllerProvider),
        ),
        data: (lista) => lista.isEmpty
            ? FletwayEmptyView(
                mensaje: 'Para ofertar necesitás al menos un vehículo.',
                icono: Icons.local_shipping_outlined,
                accion: FletwayButton(
                  texto: 'Agregar vehículo',
                  icono: Icons.add,
                  onPressed: () =>
                      context.push('/transportista/vehiculos/nuevo'),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(FletwaySpacing.lg),
                children: [
                  const FletwaySeccion(
                    icono: Icons.local_shipping_outlined,
                    titulo: 'Vehículo',
                    detalle: 'Los viajes se calculan con sus medidas y su '
                        'carga útil.',
                  ),
                  for (final v in lista)
                    _VehiculoOpcion(
                      vehiculo: v,
                      elegido: v.id == estado.vehiculoId,
                      onTap: () => controller.elegirVehiculo(v.id),
                    ),
                  const SizedBox(height: FletwaySpacing.xl),
                  FletwaySeccion(
                    icono: Icons.groups_outlined,
                    titulo: 'Ayudantes',
                    detalle: pedidos == null
                        ? 'Hasta $maxAyudantes.'
                        : 'La solicitud pide $pedidos (orientativo). '
                            'Hasta $maxAyudantes.',
                  ),
                  const SizedBox(height: FletwaySpacing.sm),
                  SegmentedButton<int>(
                    segments: [
                      for (var n = 0; n <= maxAyudantes; n++)
                        ButtonSegment(value: n, label: Text('$n')),
                    ],
                    selected: {estado.ayudantes},
                    onSelectionChanged: (s) =>
                        controller.elegirAyudantes(s.first),
                  ),
                  const SizedBox(height: FletwaySpacing.xl),
                  const FletwaySeccion(
                    icono: Icons.payments_outlined,
                    titulo: 'Precio',
                  ),
                  const SizedBox(height: FletwaySpacing.sm),
                  _Precio(cotizacion: estado.cotizacion),
                  const SizedBox(height: FletwaySpacing.xl),
                  FletwayButton(
                    texto: 'Enviar oferta',
                    icono: Icons.send_outlined,
                    anchoCompleto: true,
                    cargando: estado.enviando,
                    onPressed: estado.puedeOfertar ? enviar : null,
                  ),
                ],
              ),
      ),
    );
  }
}

class _VehiculoOpcion extends StatelessWidget {
  const _VehiculoOpcion({
    required this.vehiculo,
    required this.elegido,
    required this.onTap,
  });

  final Vehiculo vehiculo;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = vehiculo;
    final tema = Theme.of(context);
    // Un vehículo inactivo no sirve para ofertar: se explica en vez de ocultarlo.
    final motivo = v.activo ? null : 'Inactivo: activalo en Mis vehículos';
    return Padding(
      padding: const EdgeInsets.only(top: FletwaySpacing.sm),
      child: FletwayCard(
        onTap: motivo == null ? onTap : null,
        child: Row(
          children: [
            Icon(
              elegido ? Icons.radio_button_checked : Icons.radio_button_off,
              color: motivo == null
                  ? tema.colorScheme.primary
                  : tema.disabledColor,
            ),
            const SizedBox(width: FletwaySpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${v.tipoVehiculoNombre} · ${v.patente}',
                      style: tema.textTheme.titleMedium),
                  Text(
                    motivo ??
                        '${v.largoUtilM.paraCampo} × ${v.anchoUtilM.paraCampo} × '
                            '${v.altoUtilM.paraCampo} m · '
                            '${v.pesoMaximoKg.legible} kg',
                    style: tema.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Precio extends StatelessWidget {
  const _Precio({required this.cotizacion});

  final AsyncValue<Cotizacion>? cotizacion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = cotizacion;
    if (c == null) {
      return const Text('Elegí un vehículo para ver el precio.');
    }
    return c.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(FletwaySpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: tema.colorScheme.error),
          const SizedBox(width: FletwaySpacing.md),
          Expanded(child: Text(Failure.from(e).message)),
        ],
      ),
      data: (cot) => FletwayCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cot.precioCalculado.pesos,
                style: tema.textTheme.headlineMedium),
            Text(
              '${cot.cantidadViajes} '
              '${cot.cantidadViajes == 1 ? 'viaje' : 'viajes'} · '
              '${cot.cantidadAyudantes} '
              '${cot.cantidadAyudantes == 1 ? 'ayudante' : 'ayudantes'} · IVA incluido',
              style: tema.textTheme.bodyMedium,
            ),
            DesgloseOfertaView(desglose: cot.desglose),
          ],
        ),
      ),
    );
  }
}
