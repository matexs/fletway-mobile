import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/fechas.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../ofertas/data/oferta_cliente_dto.dart';

/// Confirmación del viaje recién aceptado (RF-07): quién viene, con qué
/// vehículo (recién acá se ve la patente) y cuánto se paga. El seguimiento y
/// los PIN se suman en el módulo 10.
class ViajeConfirmadoScreen extends StatelessWidget {
  /// Crea la pantalla con el [viaje] que devolvió la aceptación.
  const ViajeConfirmadoScreen({required this.viaje, super.key});

  /// Viaje confirmado; null si se abrió sin pasar por la aceptación.
  final ViajeConfirmado? viaje;

  @override
  Widget build(BuildContext context) {
    final v = viaje;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Viaje confirmado')),
      body: v == null
          ? FletwayEmptyView(
              mensaje: 'Abrí el viaje desde tus solicitudes.',
              icono: Icons.local_shipping_outlined,
              accion: FletwayButton(
                texto: 'Ir a mis solicitudes',
                onPressed: () => context.go('/cliente'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(FletwaySpacing.lg),
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: tema.extension<FletwayEstados>()!.exito),
                const SizedBox(height: FletwaySpacing.md),
                Text('¡Listo! Tu viaje está confirmado.',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.headlineSmall),
                const SizedBox(height: FletwaySpacing.xl),
                FletwayCard(
                  child: Column(
                    children: [
                      _Dato(Icons.person_outline, v.transportistaNombre,
                          'Transportista'),
                      _Dato(
                        Icons.local_shipping_outlined,
                        v.vehiculoPatente,
                        v.vehiculoMarcaModelo ?? 'Patente del vehículo',
                      ),
                      _Dato(Icons.event_outlined,
                          fechaDesdeApi(v.fechaServicioDeseada).larga, 'Fecha'),
                      _Dato(Icons.trip_origin, v.origenDireccion, 'Origen'),
                      _Dato(
                          Icons.place_outlined, v.destinoDireccion, 'Destino'),
                      _Dato(
                        Icons.payments_outlined,
                        v.montoTotal.pesos,
                        '${v.cantidadViajes} '
                        '${v.cantidadViajes == 1 ? 'viaje' : 'viajes'} · '
                        '${v.cantidadAyudantes} '
                        '${v.cantidadAyudantes == 1 ? 'ayudante' : 'ayudantes'} · IVA incluido',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FletwaySpacing.lg),
                Text(
                  'Antes de empezar y al terminar, el transportista te va a '
                  'pedir un PIN para confirmar el servicio.',
                  style: tema.textTheme.bodyMedium,
                ),
                const SizedBox(height: FletwaySpacing.xl),
                FletwayButton(
                  texto: 'Volver a la solicitud',
                  anchoCompleto: true,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.icono, this.titulo, this.detalle);

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
