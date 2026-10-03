import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/design_system/design_system.dart';
import '../../../../shared/extensions/fechas.dart';
import '../../../../shared/extensions/numeros.dart';
import '../../../../shared/widgets/widgets.dart';
import '../application/borrador_solicitud.dart';
import '../application/solicitudes_controller.dart';
import '../data/solicitud_dto.dart';
import 'selector_objeto_sheet.dart';
import 'widgets/objeto_borrador_tile.dart';
import 'widgets/objeto_manual_sheet.dart';
import 'widgets/punto_form.dart';

/// Publicación de una solicitud de traslado (RF-06): origen y destino con su
/// acceso, fecha y franja, objetos del catálogo o cargados a mano, y ayudantes.
/// No muestra ningún precio: los precios llegan con las ofertas (RN-01).
class PublicarSolicitudScreen extends ConsumerStatefulWidget {
  /// Crea la pantalla.
  const PublicarSolicitudScreen({super.key});

  @override
  ConsumerState<PublicarSolicitudScreen> createState() =>
      _PublicarSolicitudScreenState();
}

class _PublicarSolicitudScreenState
    extends ConsumerState<PublicarSolicitudScreen> {
  final _form = GlobalKey<FormState>();
  final _origen = PuntoControllers();
  final _destino = PuntoControllers();
  DateTime? _fecha;
  TimeOfDay? _desde;
  TimeOfDay? _hasta;
  var _conHorario = false;
  var _ayudantes = 0;
  var _objetos = <ObjetoBorrador>[];
  var _enviado = false;

  @override
  void dispose() {
    _origen.dispose();
    _destino.dispose();
    super.dispose();
  }

  // Al cerrarse, un diálogo o panel devuelve el foco al último campo editado y
  // abre el teclado sin que el usuario lo pida. Se suelta el foco antes de abrir.
  void _soltarFoco() => FocusManager.instance.primaryFocus?.unfocus();

  Future<void> _elegirFecha() async {
    _soltarFoco();
    final hoy = DateUtils.dateOnly(DateTime.now());
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365)),
    );
    if (f != null) setState(() => _fecha = f);
  }

  Future<void> _elegirHora({required bool desde}) async {
    _soltarFoco();
    final h = await showTimePicker(
      context: context,
      initialTime: (desde ? _desde : _hasta) ??
          TimeOfDay(hour: desde ? 9 : 13, minute: 0),
    );
    if (h != null) setState(() => desde ? _desde = h : _hasta = h);
  }

  Future<void> _agregarDelCatalogo() async {
    _soltarFoco();
    final o = await elegirObjetoDelCatalogo(context);
    if (o != null) {
      setState(() =>
          _objetos = agregarObjeto(_objetos, ObjetoBorrador.delCatalogo(o)));
    }
  }

  Future<void> _agregarManual() async {
    _soltarFoco();
    final o = await cargarObjetoManual(context);
    if (o != null) setState(() => _objetos = agregarObjeto(_objetos, o));
  }

  /// Problemas que el Form no cubre (fecha, horario y objetos), o null.
  String? _faltante() {
    if (_fecha == null) return 'Elegí la fecha del traslado.';
    if (_conHorario) {
      if (_desde == null || _hasta == null) return 'Elegí el horario completo.';
      if (_desde!.paraApi.compareTo(_hasta!.paraApi) >= 0) {
        return 'El horario de inicio tiene que ser anterior al de fin.';
      }
    }
    if (_objetos.isEmpty) return 'Agregá al menos un objeto.';
    return null;
  }

  void _publicar() {
    _soltarFoco();
    setState(() => _enviado = true);
    final formOk = _form.currentState!.validate();
    final faltante = _faltante();
    if (!formOk || faltante != null) {
      if (faltante != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(faltante)));
      }
      return;
    }
    PuntoNuevo punto(PuntoControllers p) => PuntoNuevo(
          zonaId: p.zona!.id,
          direccion: p.direccion.text.trim(),
          pisos: int.parse(p.pisos.text.trim()),
          ascensorUtilizable: p.ascensor,
          distanciaVehiculoM: FletwayTextField.leerDecimal(p.distancia.text)!,
        );
    ref.read(publicarSolicitudProvider.notifier).publicar(
          NuevaSolicitud(
            origen: punto(_origen),
            destino: punto(_destino),
            fechaServicioDeseada: _fecha!.paraApi,
            franjaHorariaInicio: _conHorario ? _desde!.paraApi : null,
            franjaHorariaFin: _conHorario ? _hasta!.paraApi : null,
            cantidadAyudantesSolicitados: _ayudantes,
            objetos: [for (final o in _objetos) o.aRequest()],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(publicarSolicitudProvider, (_, siguiente) {
      switch (siguiente) {
        case AsyncData(:final value?):
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Solicitud publicada. Te avisamos cuando lleguen ofertas.',
              ),
            ),
          );
          context.pushReplacement('/cliente/solicitudes/${value.id}');
        case AsyncError(:final error):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(Failure.from(error).message)),
          );
        default:
      }
    });
    final zonas = ref.watch(zonasSolicitudProvider);
    final envio = ref.watch(publicarSolicitudProvider);
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar solicitud')),
      body: zonas.when(
        loading: () => const FletwayLoading(),
        error: (e, _) => FletwayErrorView(
          mensaje: Failure.from(e).message,
          onReintentar: () => ref.invalidate(zonasSolicitudProvider),
        ),
        data: (lista) => Form(
          key: _form,
          autovalidateMode: _enviado
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(FletwaySpacing.lg),
            children: [
              PuntoForm(
                icono: Icons.trip_origin,
                titulo: 'Desde',
                zonas: lista,
                valores: _origen,
                onCambio: () => setState(() {}),
              ),
              const SizedBox(height: FletwaySpacing.xl),
              PuntoForm(
                icono: Icons.place_outlined,
                titulo: 'Hasta',
                zonas: lista,
                valores: _destino,
                onCambio: () => setState(() {}),
              ),
              const SizedBox(height: FletwaySpacing.xl),
              const FletwaySeccion(
                  icono: Icons.event_outlined, titulo: 'Cuándo'),
              const SizedBox(height: FletwaySpacing.sm),
              FletwayButton(
                texto: _fecha == null ? 'Elegir fecha' : _fecha!.larga,
                icono: Icons.calendar_month_outlined,
                variante: FletwayButtonVariante.secundario,
                anchoCompleto: true,
                onPressed: _elegirFecha,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.schedule),
                title: const Text('Elegir un horario'),
                subtitle: Text(
                  _conHorario
                      ? 'Franja en la que te viene bien'
                      : 'Lo antes posible',
                ),
                value: _conHorario,
                onChanged: (v) => setState(() => _conHorario = v),
              ),
              if (_conHorario)
                Row(
                  children: [
                    Expanded(
                      child: FletwayButton(
                        texto: 'Desde ${_desde?.paraApi ?? '--:--'}',
                        variante: FletwayButtonVariante.secundario,
                        onPressed: () => _elegirHora(desde: true),
                      ),
                    ),
                    const SizedBox(width: FletwaySpacing.sm),
                    Expanded(
                      child: FletwayButton(
                        texto: 'Hasta ${_hasta?.paraApi ?? '--:--'}',
                        variante: FletwayButtonVariante.secundario,
                        onPressed: () => _elegirHora(desde: false),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: FletwaySpacing.xl),
              FletwaySeccion(
                icono: Icons.inventory_2_outlined,
                titulo: 'Qué llevás',
                detalle: _objetos.isEmpty
                    ? 'Elegí del catálogo o cargá a mano lo que no esté.'
                    : 'Peso estimado total: ${pesoTotal(_objetos).legible} kg',
              ),
              for (var i = 0; i < _objetos.length; i++)
                ObjetoBorradorTile(
                  objeto: _objetos[i],
                  onCantidad: (n) => setState(
                    () => _objetos = [
                      for (var j = 0; j < _objetos.length; j++)
                        j == i ? _objetos[j].conCantidad(n) : _objetos[j],
                    ],
                  ),
                  onQuitar: () => setState(
                    () => _objetos = [..._objetos]..removeAt(i),
                  ),
                ),
              const SizedBox(height: FletwaySpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FletwayButton(
                      texto: 'Del catálogo',
                      icono: Icons.chair_outlined,
                      variante: FletwayButtonVariante.secundario,
                      onPressed: _agregarDelCatalogo,
                    ),
                  ),
                  const SizedBox(width: FletwaySpacing.sm),
                  Expanded(
                    child: FletwayButton(
                      texto: 'A mano',
                      icono: Icons.edit_note,
                      variante: FletwayButtonVariante.secundario,
                      onPressed: _agregarManual,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FletwaySpacing.xl),
              const FletwaySeccion(
                icono: Icons.groups_outlined,
                titulo: 'Ayudantes',
                detalle:
                    'Cuántas personas te gustaría que vengan para cargar. Es '
                    'orientativo: cada oferta dice con cuántos viene.',
              ),
              const SizedBox(height: FletwaySpacing.sm),
              FletwaySelector<int>(
                etiqueta: 'Ayudantes',
                valor: _ayudantes,
                opciones: [
                  for (final n in [0, 1, 2, 3])
                    FletwayOpcion(
                      valor: n,
                      texto: n == 0 ? 'Sin ayudantes' : '$n',
                    ),
                ],
                onChanged: (n) => setState(() => _ayudantes = n ?? 0),
              ),
              const SizedBox(height: FletwaySpacing.xl),
              Text(
                'No vas a ver un precio ahora: cada transportista te oferta el '
                'suyo y elegís entre las mejores.',
                style: textos.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FletwaySpacing.md),
              FletwayButton(
                texto: 'Publicar',
                icono: Icons.campaign_outlined,
                anchoCompleto: true,
                cargando: envio.isLoading,
                onPressed: _publicar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
