import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/models/zona.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../application/validadores_solicitud.dart';

/// Controladores de un origen o destino del formulario de publicación.
class PuntoControllers {
  /// Dirección escrita a mano (D-20).
  final direccion = TextEditingController();

  /// Pisos por escalera.
  final pisos = TextEditingController(text: '0');

  /// Metros a pie del vehículo a la puerta.
  final distancia = TextEditingController(text: '0');

  /// Zona elegida del catálogo.
  Zona? zona;

  /// Si hay ascensor que sirva para la carga.
  bool ascensor = false;

  /// Libera los controladores.
  void dispose() {
    direccion.dispose();
    pisos.dispose();
    distancia.dispose();
  }
}

/// Campos de un origen o destino: zona, dirección y condiciones de acceso, que
/// influyen en el precio de las ofertas (RN-01).
class PuntoForm extends StatelessWidget {
  /// Crea el formulario. [onCambio] avisa que cambió la zona o el ascensor,
  /// para redibujar.
  const PuntoForm({
    required this.icono,
    required this.titulo,
    required this.zonas,
    required this.valores,
    required this.onCambio,
    super.key,
  });

  /// Ícono de la sección.
  final IconData icono;

  /// Título de la sección ("Desde", "Hasta").
  final String titulo;

  /// Zonas para elegir.
  final List<Zona> zonas;

  /// Valores editados.
  final PuntoControllers valores;

  /// Se dispara al cambiar la zona o el ascensor.
  final VoidCallback onCambio;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FletwaySeccion(icono: icono, titulo: titulo),
          const SizedBox(height: FletwaySpacing.md),
          FletwaySelector<Zona>(
            etiqueta: 'Zona',
            valor: valores.zona,
            opciones: [
              for (final z in zonas)
                FletwayOpcion(
                  valor: z,
                  texto: z.provincia == 'CABA'
                      ? z.nombre
                      : '${z.nombre} (${z.provincia})',
                ),
            ],
            onChanged: (z) {
              valores.zona = z;
              onCambio();
            },
            validator: (z) => z == null ? 'Elegí la zona.' : null,
          ),
          const SizedBox(height: FletwaySpacing.md),
          FletwayTextField(
            etiqueta: 'Dirección',
            ayuda: 'Calle, número y piso o depto. si corresponde.',
            controller: valores.direccion,
            validator: ValidadoresSolicitud.direccion,
            accionTeclado: TextInputAction.next,
          ),
          const SizedBox(height: FletwaySpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FletwayTextField.decimal(
                  etiqueta: 'Pisos por escalera',
                  decimales: 0,
                  controller: valores.pisos,
                  validator: ValidadoresSolicitud.pisos,
                ),
              ),
              const SizedBox(width: FletwaySpacing.md),
              Expanded(
                child: FletwayTextField.decimal(
                  etiqueta: 'Distancia a pie',
                  sufijo: 'm',
                  decimales: 1,
                  controller: valores.distancia,
                  validator: ValidadoresSolicitud.distancia,
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.elevator_outlined),
            title: const Text('Hay ascensor para la carga'),
            value: valores.ascensor,
            onChanged: (v) {
              valores.ascensor = v;
              onCambio();
            },
          ),
        ],
      );
}
