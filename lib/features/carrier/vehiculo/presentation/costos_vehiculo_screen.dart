import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/costos_controller.dart';
import '../application/validadores_vehiculo.dart';
import '../data/vehiculo_dto.dart';

/// Un campo del formulario de costos: clave, etiqueta, unidad, ayuda y reglas.
typedef _Campo = ({
  String clave,
  String etiqueta,
  String sufijo,
  String ayuda,
  String? Function(String?) validar,
  int decimales,
});

final _montoNoNegativo = ValidadoresVehiculo.rango(min: 0, max: 999999999999);

/// Campos en el orden del formulario. La ayuda explica cómo entra cada uno en el
/// precio (docs/ALGORITMO_COTIZACION.md §4.2) para que el Transportista sepa qué
/// valor poner.
final List<_Campo> _campos = [
  (
    clave: 'combustible_precio_l',
    etiqueta: 'Precio del combustible',
    sufijo: r'$/litro',
    ayuda: 'Lo que pagás hoy el litro del combustible que usa este vehículo.',
    validar: _montoNoNegativo,
    decimales: 2,
  ),
  (
    clave: 'rendimiento_km_l',
    etiqueta: 'Rendimiento',
    sufijo: 'km/litro',
    ayuda: 'Cuántos kilómetros hacés con un litro, cargado.',
    validar: ValidadoresVehiculo.rango(min: 0, max: 9999, minExclusivo: true),
    decimales: 2,
  ),
  (
    clave: 'cantidad_neumaticos',
    etiqueta: 'Cantidad de neumáticos',
    sufijo: '',
    ayuda: 'Incluí los de los ejes traseros duales, si tiene.',
    validar: ValidadoresVehiculo.entero(min: 1, max: 30),
    decimales: 0,
  ),
  (
    clave: 'costo_neumatico',
    etiqueta: 'Precio de un neumático',
    sufijo: r'$',
    ayuda: 'Lo que cuesta reemplazar uno.',
    validar: _montoNoNegativo,
    decimales: 2,
  ),
  (
    clave: 'vida_neumatico_km',
    etiqueta: 'Duración de un neumático',
    sufijo: 'km',
    ayuda: 'Kilómetros que dura un neumático antes de cambiarlo.',
    validar:
        ValidadoresVehiculo.rango(min: 0, max: 9999999999, minExclusivo: true),
    decimales: 0,
  ),
  (
    clave: 'costo_mantenimiento_km',
    etiqueta: 'Mantenimiento por kilómetro',
    sufijo: r'$/km',
    ayuda: 'Service, aceite, frenos y reparaciones de un año, dividido por los '
        'kilómetros que hacés en el año.',
    validar: _montoNoNegativo,
    decimales: 2,
  ),
  (
    clave: 'valor_compra',
    etiqueta: 'Valor del vehículo',
    sufijo: r'$',
    ayuda: 'Lo que costaría comprarlo hoy.',
    validar: _montoNoNegativo,
    decimales: 2,
  ),
  (
    clave: 'valor_residual',
    etiqueta: 'Valor al final de su vida útil',
    sufijo: r'$',
    ayuda:
        'Lo que pensás que vale cuando lo vendas. La diferencia con el valor '
            'del vehículo es lo que se gasta con el uso.',
    validar: _montoNoNegativo,
    decimales: 2,
  ),
  (
    clave: 'vida_util_km',
    etiqueta: 'Vida útil',
    sufijo: 'km',
    ayuda: 'Kilómetros que le quedan de uso hasta venderlo.',
    validar:
        ValidadoresVehiculo.rango(min: 0, max: 9999999999, minExclusivo: true),
    decimales: 0,
  ),
  (
    clave: 'seguro_mensual',
    etiqueta: 'Seguro',
    sufijo: r'$/mes',
    ayuda: 'Cuota mensual del seguro del vehículo.',
    validar: _montoNoNegativo,
    decimales: 2,
  ),
  (
    clave: 'patente_mensual',
    etiqueta: 'Patente',
    sufijo: r'$/mes',
    ayuda: 'Impuesto automotor, llevado a un mes.',
    validar: _montoNoNegativo,
    decimales: 2,
  ),
];

/// Costos operativos de un vehículo (RN-01): segundo paso del alta y edición
/// posterior. Sólo los ven el Transportista dueño y el Administrador.
class CostosVehiculoScreen extends ConsumerStatefulWidget {
  /// Crea la pantalla para el vehículo [vehiculoId].
  const CostosVehiculoScreen({required this.vehiculoId, super.key});

  /// Vehículo cuyos costos se cargan.
  final String vehiculoId;

  @override
  ConsumerState<CostosVehiculoScreen> createState() =>
      _CostosVehiculoScreenState();
}

class _CostosVehiculoScreenState extends ConsumerState<CostosVehiculoScreen> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _valores = {
    for (final c in _campos) c.clave: TextEditingController(),
  };
  var _precargado = false;
  var _enviado = false;
  var _guardando = false;

  @override
  void dispose() {
    for (final c in _valores.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _precargar(CostosVehiculo? costos) {
    if (_precargado || costos == null) return;
    _precargado = true;
    costos.toJson().forEach((clave, valor) {
      _valores[clave]?.text = (valor as num).paraCampo;
    });
  }

  String? _validarResidual(String? valor) {
    final base = _montoNoNegativo(valor);
    if (base != null) return base;
    final compra = FletwayTextField.leerDecimal(_valores['valor_compra']!.text);
    final residual = FletwayTextField.leerDecimal(valor);
    if (compra != null && residual != null && residual > compra) {
      return 'No puede superar el valor del vehículo.';
    }
    return null;
  }

  Future<void> _guardar() async {
    setState(() => _enviado = true);
    if (!_form.currentState!.validate()) return;
    final json = <String, dynamic>{
      for (final c in _campos)
        c.clave: c.clave == 'cantidad_neumaticos'
            ? int.parse(_valores[c.clave]!.text.trim())
            : FletwayTextField.leerDecimal(_valores[c.clave]!.text),
    };
    setState(() => _guardando = true);
    final falla = await ref
        .read(costosControllerProvider(widget.vehiculoId).notifier)
        .guardar(CostosVehiculo.fromJson(json));
    if (!mounted) return;
    setState(() => _guardando = false);
    if (falla != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(falla.message)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Costos guardados.')));
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final costos = ref.watch(costosControllerProvider(widget.vehiculoId));
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Costos del vehículo')),
      body: costos.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: () =>
              ref.invalidate(costosControllerProvider(widget.vehiculoId)),
        ),
        data: (actuales) {
          _precargar(actuales);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(FletwaySpacing.xl),
            child: Form(
              key: _form,
              autovalidateMode: _enviado
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Con estos datos calculamos el precio de cada oferta que '
                    'hagas con este vehículo. Sólo los ves vos: los Clientes '
                    'ven el precio final.',
                    style: textos.bodyMedium,
                  ),
                  for (final c in _campos) ...[
                    const SizedBox(height: FletwaySpacing.lg),
                    FletwayTextField.decimal(
                      etiqueta: c.etiqueta,
                      sufijo: c.sufijo.isEmpty ? null : c.sufijo,
                      ayuda: c.ayuda,
                      decimales: c.decimales,
                      controller: _valores[c.clave],
                      validator: c.clave == 'valor_residual'
                          ? _validarResidual
                          : c.validar,
                    ),
                  ],
                  const SizedBox(height: FletwaySpacing.xl),
                  FletwayButton(
                    texto: 'Guardar costos',
                    onPressed: _guardar,
                    cargando: _guardando,
                    anchoCompleto: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
