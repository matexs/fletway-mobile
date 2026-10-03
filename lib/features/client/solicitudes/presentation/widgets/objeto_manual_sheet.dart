import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../application/borrador_solicitud.dart';
import '../../application/validadores_solicitud.dart';

/// Abre un panel para cargar a mano un objeto que no está en el catálogo
/// (RN-08). Devuelve el objeto, o null si se cierra.
Future<ObjetoBorrador?> cargarObjetoManual(BuildContext context) =>
    showModalBottomSheet<ObjetoBorrador>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _ObjetoManualForm(),
      ),
    );

class _ObjetoManualForm extends StatefulWidget {
  const _ObjetoManualForm();

  @override
  State<_ObjetoManualForm> createState() => _ObjetoManualFormState();
}

class _ObjetoManualFormState extends State<_ObjetoManualForm> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _peso = TextEditingController();
  final _largo = TextEditingController();
  final _ancho = TextEditingController();
  final _alto = TextEditingController();
  var _seAcuesta = true;
  var _apilable = true;

  @override
  void dispose() {
    for (final c in [_nombre, _peso, _largo, _ancho, _alto]) {
      c.dispose();
    }
    super.dispose();
  }

  void _agregar() {
    if (!_form.currentState!.validate()) return;
    double leer(TextEditingController c) =>
        FletwayTextField.leerDecimal(c.text)!;
    Navigator.of(context).pop(
      ObjetoBorrador.manual(
        nombre: _nombre.text.trim(),
        pesoKg: leer(_peso),
        largoM: leer(_largo),
        anchoM: leer(_ancho),
        altoM: leer(_alto),
        seAcuesta: _seAcuesta,
        apilable: _apilable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(FletwaySpacing.lg),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FletwaySeccion(
                icono: Icons.edit_note,
                titulo: 'Objeto que no está en el catálogo',
                detalle:
                    'Medilo con la mayor precisión que puedas: con estas medidas '
                    'se calcula cuántos viajes hacen falta.',
              ),
              const SizedBox(height: FletwaySpacing.lg),
              FletwayTextField(
                etiqueta: 'Qué es',
                controller: _nombre,
                validator: ValidadoresSolicitud.nombreObjeto,
              ),
              const SizedBox(height: FletwaySpacing.md),
              FletwayTextField.decimal(
                etiqueta: 'Peso aproximado',
                sufijo: 'kg',
                controller: _peso,
                validator: ValidadoresSolicitud.positivo(2000),
              ),
              const SizedBox(height: FletwaySpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (etiqueta, c) in [
                    ('Largo', _largo),
                    ('Ancho', _ancho),
                    ('Alto', _alto),
                  ]) ...[
                    Expanded(
                      child: FletwayTextField.decimal(
                        etiqueta: etiqueta,
                        sufijo: 'm',
                        controller: c,
                        validator: ValidadoresSolicitud.positivo(10),
                      ),
                    ),
                    if (etiqueta != 'Alto')
                      const SizedBox(width: FletwaySpacing.sm),
                  ],
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.screen_rotation_alt_outlined),
                title: const Text('Se puede acostar'),
                value: _seAcuesta,
                onChanged: (v) => setState(() => _seAcuesta = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.layers_outlined),
                title: const Text('Se le puede poner carga encima'),
                value: _apilable,
                onChanged: (v) => setState(() => _apilable = v),
              ),
              const SizedBox(height: FletwaySpacing.md),
              FletwayButton(
                  texto: 'Agregar', icono: Icons.add, onPressed: _agregar),
            ],
          ),
        ),
      );
}
