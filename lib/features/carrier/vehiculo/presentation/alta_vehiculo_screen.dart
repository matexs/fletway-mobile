import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/alta_vehiculo_controller.dart';
import '../application/validadores_vehiculo.dart';
import '../application/vehiculos_controller.dart';
import '../data/vehiculo_dto.dart';

/// Alta de un vehículo (RF-18). Al elegir el tipo se proponen sus medidas
/// estándar (D-32), que el Transportista corrige con las reales de la caja.
/// Los costos no se cargan: son de referencia por tipo (D-34).
class AltaVehiculoScreen extends ConsumerStatefulWidget {
  /// Crea la pantalla.
  const AltaVehiculoScreen({super.key});

  @override
  ConsumerState<AltaVehiculoScreen> createState() => _AltaVehiculoScreenState();
}

class _AltaVehiculoScreenState extends ConsumerState<AltaVehiculoScreen> {
  final _form = GlobalKey<FormState>();
  final _patente = TextEditingController();
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _largo = TextEditingController();
  final _ancho = TextEditingController();
  final _alto = TextEditingController();
  final _peso = TextEditingController();
  TipoVehiculo? _tipo;
  var _enviado = false;

  @override
  void dispose() {
    for (final c in [_patente, _marca, _modelo, _largo, _ancho, _alto, _peso]) {
      c.dispose();
    }
    super.dispose();
  }

  void _elegirTipo(TipoVehiculo? tipo) {
    if (tipo == null) return;
    setState(() => _tipo = tipo);
    _largo.text = tipo.largoEstandarM.paraCampo;
    _ancho.text = tipo.anchoEstandarM.paraCampo;
    _alto.text = tipo.altoEstandarM.paraCampo;
    _peso.text = tipo.pesoMaximoEstandarKg.paraCampo;
  }

  void _guardar() {
    setState(() => _enviado = true);
    if (!_form.currentState!.validate()) return;
    String? opcional(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    ref.read(altaVehiculoControllerProvider.notifier).crear(
          NuevoVehiculo(
            tipoVehiculoId: _tipo!.id,
            patente: ValidadoresVehiculo.normalizarPatente(_patente.text),
            marca: opcional(_marca),
            modelo: opcional(_modelo),
            largoUtilM: FletwayTextField.leerDecimal(_largo.text)!,
            anchoUtilM: FletwayTextField.leerDecimal(_ancho.text)!,
            altoUtilM: FletwayTextField.leerDecimal(_alto.text)!,
            pesoMaximoKg: FletwayTextField.leerDecimal(_peso.text)!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(altaVehiculoControllerProvider, (_, siguiente) {
      switch (siguiente) {
        case AsyncData(:final value?):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vehículo ${value.patente} agregado.')),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/transportista/vehiculos');
          }
        case AsyncError(:final error):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(Failure.from(error).message)),
          );
        default:
      }
    });
    final tipos = ref.watch(tiposVehiculoProvider);
    final envio = ref.watch(altaVehiculoControllerProvider);
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo vehículo')),
      body: tipos.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: () => ref.invalidate(tiposVehiculoProvider),
        ),
        data: (lista) => SingleChildScrollView(
          padding: const EdgeInsets.all(FletwaySpacing.xl),
          child: Form(
            key: _form,
            autovalidateMode: _enviado
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FletwaySelector<TipoVehiculo>(
                  etiqueta: 'Tipo de vehículo',
                  valor: _tipo,
                  opciones: [
                    for (final t in lista)
                      FletwayOpcion(valor: t, texto: t.nombre),
                  ],
                  onChanged: _elegirTipo,
                  validator: (t) => t == null ? 'Elegí el tipo.' : null,
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField(
                  etiqueta: 'Patente',
                  controller: _patente,
                  validator: ValidadoresVehiculo.patente,
                  accionTeclado: TextInputAction.next,
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField(
                  etiqueta: 'Marca (opcional)',
                  controller: _marca,
                  accionTeclado: TextInputAction.next,
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField(
                  etiqueta: 'Modelo (opcional)',
                  controller: _modelo,
                  accionTeclado: TextInputAction.next,
                ),
                const SizedBox(height: FletwaySpacing.xl),
                Text('Medidas útiles de la caja', style: textos.titleMedium),
                const SizedBox(height: FletwaySpacing.xs),
                Text(
                  _tipo == null
                      ? 'Elegí el tipo y te proponemos medidas de referencia.'
                      : 'Son las medidas de referencia de un ${_tipo!.nombre}. '
                          'Corregilas con las de tu vehículo: con ellas '
                          'calculamos cuántos viajes hacen falta.',
                  style: textos.bodyMedium,
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField.decimal(
                  etiqueta: 'Largo',
                  sufijo: 'm',
                  controller: _largo,
                  validator: ValidadoresVehiculo.rango(
                    min: 0,
                    max: 20,
                    minExclusivo: true,
                  ),
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField.decimal(
                  etiqueta: 'Ancho',
                  sufijo: 'm',
                  controller: _ancho,
                  validator: ValidadoresVehiculo.rango(
                    min: 0,
                    max: 3,
                    minExclusivo: true,
                  ),
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField.decimal(
                  etiqueta: 'Alto',
                  sufijo: 'm',
                  controller: _alto,
                  validator: ValidadoresVehiculo.rango(
                    min: 0,
                    max: 5,
                    minExclusivo: true,
                  ),
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField.decimal(
                  etiqueta: 'Carga útil',
                  sufijo: 'kg',
                  ayuda:
                      'Lo que puede llevar, sin contar el peso del vehículo.',
                  controller: _peso,
                  validator: ValidadoresVehiculo.rango(
                    min: 0,
                    max: 40000,
                    minExclusivo: true,
                  ),
                ),
                const SizedBox(height: FletwaySpacing.xl),
                FletwayButton(
                  texto: 'Guardar vehículo',
                  onPressed: _guardar,
                  cargando: envio.isLoading,
                  anchoCompleto: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
