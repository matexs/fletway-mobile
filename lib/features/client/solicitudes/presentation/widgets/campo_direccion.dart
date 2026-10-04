import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_system.dart';
import '../../../../../shared/models/zona.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../data/direcciones_repository.dart';

/// Campo de dirección con autocompletado dentro de la zona elegida (D-35 del
/// backend). Las sugerencias aparecen debajo mientras se escribe; elegir una
/// completa el campo con la calle y la altura. Si no hay sugerencias se puede
/// seguir escribiendo a mano: el backend ubica la dirección al publicar.
class CampoDireccion extends ConsumerStatefulWidget {
  /// Crea el campo. Sin [zona] no busca sugerencias.
  const CampoDireccion({
    required this.controller,
    required this.zona,
    this.validator,
    super.key,
  });

  /// Texto de la dirección.
  final TextEditingController controller;

  /// Zona donde buscar.
  final Zona? zona;

  /// Validación del formulario.
  final FormFieldValidator<String>? validator;

  @override
  ConsumerState<CampoDireccion> createState() => _CampoDireccionState();
}

class _CampoDireccionState extends ConsumerState<CampoDireccion> {
  /// Espera entre teclas antes de pedir sugerencias, para no pedir una por
  /// letra.
  static const _espera = Duration(milliseconds: 400);

  Timer? _timer;
  List<SugerenciaDireccion> _sugerencias = const [];
  bool _buscando = false;
  // Texto que se completó eligiendo una sugerencia: no vuelve a buscar.
  String? _elegido;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(CampoDireccion viejo) {
    super.didUpdateWidget(viejo);
    if (viejo.zona != widget.zona) setState(() => _sugerencias = const []);
  }

  void _alEscribir(String texto) {
    _timer?.cancel();
    final zona = widget.zona;
    if (zona == null || texto.trim().length < 3 || texto == _elegido) {
      setState(() => _sugerencias = const []);
      return;
    }
    _timer = Timer(_espera, () => _buscar(zona.id, texto.trim()));
  }

  Future<void> _buscar(String zonaId, String texto) async {
    setState(() => _buscando = true);
    List<SugerenciaDireccion> lista;
    try {
      lista = await ref
          .read(direccionesRepositoryProvider)
          .sugerencias(zonaId, texto);
    } catch (_) {
      // Sin sugerencias se sigue escribiendo a mano.
      lista = const [];
    }
    if (!mounted || widget.controller.text.trim() != texto) return;
    setState(() {
      _buscando = false;
      _sugerencias = lista;
    });
  }

  void _elegir(SugerenciaDireccion s) {
    _elegido = s.direccion;
    widget.controller.value = TextEditingValue(
      text: s.direccion,
      selection: TextSelection.collapsed(offset: s.direccion.length),
    );
    setState(() => _sugerencias = const []);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FletwayTextField(
          etiqueta: 'Dirección',
          ayuda: widget.zona == null
              ? 'Elegí la zona primero y te sugerimos direcciones.'
              : 'Empezá a escribir la calle y el número.',
          controller: widget.controller,
          validator: widget.validator,
          onChanged: _alEscribir,
          accionTeclado: TextInputAction.next,
          sufijo: _buscando ? '…' : null,
        ),
        if (_sugerencias.isNotEmpty)
          FletwayCard(
            child: Column(
              children: [
                for (final s in _sugerencias)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.place_outlined,
                        color: tema.colorScheme.primary),
                    title: Text(s.direccion),
                    subtitle: s.detalle.isEmpty ? null : Text(s.detalle),
                    onTap: () => _elegir(s),
                  ),
              ],
            ),
          ),
        if (_sugerencias.isEmpty && !_buscando)
          const SizedBox(height: FletwaySpacing.xs),
      ],
    );
  }
}
